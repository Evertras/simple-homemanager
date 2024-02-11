# 05 - Explanation: Flake.nix output function body

[<- Explanation: Flake.nix output function syntax](04-explain-outputs-function.md)

In the last section we took our first look at the `outputs` field in
`flake.nix`. You should now understand:

- The syntax of a Nix function definition
- What `let in` syntax is
- What `inherit` means

In this section we'll finally wrap up our explanation of our initial
`flake.nix` by looking at what the `outputs` function actually does.

For reference, here's the whole thing.

```nix
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
```

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

## The `homeConfigurations` field

Now let's take a look at the final piece of the `flake.nix` puzzle.

```nix
homeConfigurations = {
  myprofile = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [ ./home.nix ];
  };
};
```

### The `home-manager switch` command explained

In this case, `homeConfigurations` is another attribute set.  Each field in
`homeConfigurations` is the name of a user profile.  You may have noticed in
our Makefile we used this command:

```bash
home-manager switch --flake .#myprofile
```

This is a syntax used often with flakes where you specify a path to the flake,
followed by some `#selector`.  In our case, that `.` means the current path.
The `#myprofile` means to select the profile named `myprofile` from the list of
`homeConfigurations`.  If we wanted to have multiple profiles, we could add them
to our `outputs` and select them with `#` in the same way.

### The value of `myprofile`

The value of `myprofile` is another attribute set.  Surprise!  It's always
another attribute set.

Just like `nixpkgs`, `home-manager` comes with its own `lib` which is (say it
with me) another attribute set.  One of the values, `homeManagerConfiguration`,
is a function which generates the actual output that `home-manager` uses.

As input to this `homeManagerConfiguration` function, we need to provide it with
the definition of all potential packages for us to install as well as the actual
configuration we defined for ourselves.  Generally this will be the `pkgs` we
defined earlier to tell `home-manager` about all the `nixpkgs` for our system.
Once again we conveniently named our intermediate variable `pkgs` so we just
use `inherit`.  Again, this is just a different way of saying `pkgs = pkgs;`
to stick with Nix conventions.

We also need to provide it with a list of 'modules'.  Here we give it our
`home.nix` file.

### Paths

You might have expected `home.nix` to be provided as a string.  However, Nix is
a language that's purpose built to deal with packaging, configuration, etc.
Because of that, paths are actually a [first-class data type](https://nixos.org/manual/nix/stable/language/values#type-path).

Generally every path you use will be a relative path from the root of the flake.
The actual name `home.nix` doesn't matter.  You could also put it in a
subdirectory, like `modules/home.nix` or `configurations/myprofile/home.nix`.
You'll start doing this as you get more and more configuration code together.

#### Aside: Magical filenames

There are two mgaical filenames to be aware of.  The first is `flake.nix`.
This is a file used by various flake commands, as you might expect.

The second is `default.nix`.  If you ever import a directory, Nix will look for
a `default.nix` file in that directory.  This can make for nice clean imports,
and may be worth exploring later.

But for now, `home.nix` is fine.

## Summary

We've gone through the entire `flake.nix` file now.  From this section, you
should understand:

- The `outputs` function produces an attribute set
  - That attribute set can contain different things depending on the use of the flake
- `home-manager` wants to see a `homeConfigurations` field
  - Each field represents a single user profile
  - The field is generated using `home-manager.lib.homeManagerConfiguration`
- We can select the profile we want to use with `home-manager switch --flake .#insertprofilehere`

At this point you should be able to look at each line of `flake.nix` and have
some familiarity with what it's actually saying.  You do not have to be able to
write this from scratch or be able to give an in-depth explanation of each line.
As long as you can look at a line and think, "Yeah I see that's `X`" then you're
good to go, and you can always come back later as you play with things more.
