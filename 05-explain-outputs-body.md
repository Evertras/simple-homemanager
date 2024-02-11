# 05 - Explanation: Flake.nix output function body

[<- Explanation: Flake.nix output function syntax](04-explain-outputs-function.md)

In the last section we took our first look at the `outputs` field in
`flake.nix`. You should now understand:

- The syntax of a Nix function definition
- What `let in` syntax is
- What `inherit` means

In this section we'll finally wrap up our explanation of our initial
`flake.nix`.

## What should `outputs` produce?

First, another quiz! With your current knowledge, you should be able to
understand this expression:

```nix
{ a, b }: { sum = a + b; };
```

What does this function do? Think about it, then I'll explain.

This function takes a single argument. That argument is an attribute set that
contains the fields `a` and `b`. The function returns a new attribute set,
which then contains a single filed `sum` that is equal to `a + b`.

Got it? Great. Now let's look at our outputs function again, but let's remove
all the extra noise to focus on what it's actually constructing.

```nix
  # Vastly simplified
  outputs = { nixpkgs, home-manager, ... }:
    {
      homeConfigurations = "<something>";
    };
```

So what does this say? It says that the `outputs` field of the attribute set
defined by the `flake.nix` file is a function. That function takes an attribute
set which contains `nixpkgs` and `home-manager`, as well as allowing any other
random fields that we don't care about. It creates an attribute set that
contains a single field: `homeConfigurations`.

This is the same structure as the `{ a, b }: { sum = a + b; }` function we
looked at above. There's nothing special about it from a syntax point of view.

The important takeaway here is that `outputs` needs to be a function that takes
some attribute set consisting of our `inputs` and it must produce a new
attribute set.

What should the values of that output attribute set be? It depends on what the
flake is being used for. Nix actually knows about [various special fields](https://nixos.wiki/wiki/Flakes#Output_schema)
which are worth glancing at. In particular, `nixosConfigurations` would be what
you want to define a NixOS system. But today we want none of those, and you'll
notice at the end of that list it reads:

> You can also define additional arbitrary attributes, but these are the outputs that Nix knows about.

In our particular case, we only care about creating
a definition that home-manager can use. This is done by defining the
`homeConfigurations` field in the output attribute set.

How do you know it's `homeConfigurations`? You copy/paste it from somewhere
else. The [official docs](https://nix-community.github.io/home-manager/index.xhtml#sec-flakes-standalone)
say to run `home-manager init` which will get you there eventually, but honestly
it's a bit frustrating that this isn't easily laid out somewhere as of the time
of this writing (early 2024). Again, welcome to Nix!

Anyway, that aside, you have a source to copy/paste from now. And now you should
understand the following:

- The `outputs` field in `flake.nix` is a function that produces an attribute set
- The attribute set can contain any fields, depending on what the intended use of the flake is
- Our use requires us to define a `homeConfigurations` field
