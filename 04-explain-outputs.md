# 04 - Explanation: Flake.nix outputs

[<- Explanation: Basic Nix syntax and flake.nix inputs](./03-explain-inputs.md)

In the last section we covered some basic Nix syntax, the `description` field,
and the `inputs` field.

Again, you should now understand:

- What a Nix attribute set is
- How the `.` notation works
- That the `inputs` field is a Nix attribute set with arbitrary fields

[Go back if you don't.](./03-checkpoint-explanation.md)

Now let's tackle the scarier `outputs` field. We'll need to learn some more
Nix syntax, so we'll jump back and forth between new syntax and how it applies
to the `outputs` field.

This is going to be long. If this doesn't convince you that you were right
to not dive into the rabbit holes of Nix docs on your own, nothing will.

_If you don't understand this section the first time, that's fine. Come back
to it later for reference as you tinker more. The important takeaway for you
here is that these things exist as concepts to refer to later._

## Outputs

A quick refresher, here's our current `outputs` in its entirety.

```nix
{
  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations = {
        myprofile = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
      };
    };
}
```

Hope you're ready for some fun, because there's a lot to unpack here.

## Nix functions

Nix would be terribly boring if it was just a glorified JSON format, which is
all we've seen so far. But Nix is a full functional language, so let's see what
a function in Nix looks like. Note that this isn't named or usable anywhere
yet. We'll get to how to actually define practical usable functions later. Just
focus on the syntax for now, because you'll see it nested everywhere inside
things.

```nix
# argument
# |
# v
  a: a + 2
#    ^^^^^
#     |
#     result
```

There's a single argument `a`. The result is `a + 2`. Simple!

There can only ever be one argument in a Nix function. This allows a lot of
really cool stuff like currying. We'll leave that for another day, so for now
just know that a function always has exactly one argument.

Functions can (and often do) take an attribute set as an argument. The Nix
syntax allows us to _deconstruct_ the incoming attribute set into specific
fields that we expect. When we do this, the input fields _must_ be provided
(unless we do some other fancy default syntax, which is for another day).

```nix
# A function that takes an attribute set with fields `a` and `b` and returns
# `a + b`.

# argument (still single!)
#    |
# vvvvvvvv
  { a, b }: a + b
#           ^^^^^
#             |
#           result
```

Any call of this function must provide exactly `a` and `b` in the attribute set.
It cannot provide anything else.

Remember that a Nix file can only ever be a single expression. This means that
you're not going to define functions in a global scope to call later. So where
do they come from? How do we call them? We'll see as we go, this is already
tons of information for you to worry about!

The important things to know right now:

- Functions always have exactly one argument
- Functions can take an attribute set as an argument
- Functions always evaluate to a single expression

## The `outputs` function

Ok, let's finally get back to our `outputs` field. Specifically, the first
line.

```nix
#           argument
#              |
#         vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
outputs = { nixpkgs, home-manager, ... }:
```

We are assigning the field `outputs` to a function! You can tell by the `:` at
the end. This function takes a single argument, which is an attribute set,
similar to our `{ a, b }: a + b` example. The attribute set must have the
fields `nixpkgs` and `home-manager` at a minimum, and the `...` is a special
Nix way of saying "and anything else is fine too but I'll ignore it".

Where did `nixpkgs` and `home-manager` come from? `inputs` of course! The
field names are arbitrary in `inputs`, and they will be passed verbatim to the
arguments of the `outputs` function. You can try renaming `nixpkgs` to `idk`
and try to rebuild it, but it won't work until you also rename the argument in
the `outputs` function to `idk` as well.

What do these arguments hold? Magic.

Technically they hold the `outputs` result of the flake that was passed in as
`inputs`, but I'd recommend saving that exploration for another day and just
kind of trusting what's going on here for now.

## Let/in syntax

Because every nix expression must be a single expression, this can get really
verbose really fast with a lot of parenthesis. So instead we can use `let in`
to create some intermediate variables for us. Briefly, here's what `let in`
syntax looks like:

```nix
# Evaluates to the number 4
let a = 2; in a + 2
```

You can create multiple variables in the `let`, and use whitespace:

```nix
# Evaluates to the number 6
let
  a = 2;
  b = 3;
in a * b
```

You can even re-use those variables in the same `let`:

```nix
# Evaluates to the number 7
let
  a = 2;
  b = a + 1;
in a + b + 2
```

Remember that functions are expressions too, which is one way we can define
and use functions for ourselves:

```nix
# Evaluates to the number 8
let
  double = a: a * 2;
in double 4
```

This is a very powerful tool we can use a lot in the future! But for now, let's
get back to what this whole `let in` thing means for our `outputs` function.

## Let/in for `outputs`

You should now understand the following:

- `let in` defines some intermediate values that can be used inside the expression that follows
- Things defined in `let in` can be used inside the same `let in` block

With that in mind, let's look at the `let in` block in our `outputs` function.

```nix
let
  lib = nixpkgs.lib;
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };
in { #...
```

Ok. Let's take these one at a time.

```nix
lib = nixpkgs.lib;
```

Remember how above I told you that `nixpkgs` also contains a giant standard
library of sorts for Nix? [This is that standard library.](https://nixos.org/manual/nixpkgs/stable/#id-1.4)
You may want to bookmark that, but for now just take a glance and be convinced
that there's a lot of stuff there. If you really want to dig deeper, you can
[look at the Github repository.](https://github.com/NixOS/nixpkgs/tree/master/lib)

Ok, so we have `lib`. Let's look at the next.

```nix
system = "x86_64-linux";
```

This is a simple string literal, so you should be familiar with this. What's
this value about?

Nix works for [most Linux and Mac systems](https://nixos.org/manual/nix/stable/installation/supported-platforms).
However, you need to tell Nix what system you're on, so that it can fetch the
correct packages for your OS and architecture. In this case, I'm assuming
you're on a 64 bit Linux system. If you're not, you'll need to change this
to the appropriate value after finding it yourself.

This `system` variable isn't magical, though. Nothing in this `let` has a
magical name of any sort, it's all arbitrary. We could have set
`steve = "x86_64-linux;" if we wanted to. So how do we use it? The next line
answers that.

```nix
pkgs = import nixpkgs { inherit system; };
```

There's a _lot_ going on here, so let's take this one step at a time.

### What's `import`?

Usually `import` is actually [used on files](https://nixos.org/manual/nix/stable/language/builtins.html#builtins-import).
We'll actually be using it a lot later when we want to split up our
configuration into multiple files locally. Here, there's a bit of magic going
on. [This explains why we can use it on a flake.](https://stackoverflow.com/questions/74464687/whats-the-mechanism-behind-import-nixpkgs-in-nix-flakes)

The short version is smile, nod, and understand that `import nixpkgs` evaluates
to a function that we can call.

#### Using `import` vs `legacyPackages`

As an aside, you may see some examples out there with some field of
`legacyPackages` instead of `import`. Both are the same, but `legacyPackages`
may actually be faster in more complicated setups that would `import` multiple
times. If you want to geek out, [check this thread](https://discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/7).
For now, we're going with `import` because it allowed me to introduce `import`
in the first place, and I always feel wary of using anything with `legacy`
in the name even if it's [not actually deprecated but rather just a naming thing.](https://github.com/NixOS/nixpkgs/blob/master/flake.nix#L64)

### The function call and `inherit`

Remember that `import nixpkgs` returns a function that we can call. And
remember from above that a function call takes a single argument. In this case
the argument is an attribute set, and it requires `system`.

How are you supposed to know this? You read it somewhere and copy/paste like
the rest of us. _Welcome to Nix!_

Ok, so we want to give it an attribute set, and we want to give it the field
`system`. So what's this `inherit system` about? Basically, `inherit a;` is
exactly the same as `a = a;`.

```nix
let
  a = 3;
  # The following declarations are exactly the same
  b = { inherit a; };
  c = { a = a };
in
  # ...
```

So in our example, `inherit system` is just saying `system = system;`. It's
a commonly used shortcut in Nix, and you'll see it a lot. Why bother? It gets
more useful when you have multiple fields to inherit, like so:

```nix
let
  a = 3;
  b = 4;
  # The following declarations are exactly the same
  c = { inherit a b; };
  d = { a = a; b = b; };
in
  # ...
```

You can also do some neat tricks with `inherit` to grab nested fields, but
that's for another day. Just get used to the basics of `inherit` for now.

### Bringing it all together

Ok, so that was a lot! Let's bring it all together.

```nix

```
