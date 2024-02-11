# 03 - Explanation: Basic Nix syntax and flake.nix inputs

[<- 02 - Basic Repository Setup](./02-basic-repository-setup.md) | [04 - Explanation: The flake.nix output function ->](./04-explain-outputs-function.md)

As a reward for sticking with me and getting your first home manager flake set
up, let's actually go back and explain everything now! It's important to have
a working example for context.

I'm going to try and give high level explanations. The rabbit holes are still
deep, so be careful how much you try to delve from here until you get more under
your belt. Hopefully just seeing how much there is to explain in these small
files will reassure you to take it slow.

I will add links to relevant documentation or other information. They can be
good to look at, but **be careful not to get lost in them**. Save them for later
to revisit as you become more familiar with Nix things.

_If you don't understand these sections the first time, that's fine. Come back
to it later for reference as you tinker more. The important takeaway for you
here is that these things exist as concepts to refer to later._

## What is a flake?

The term "flake" plays off Nix's logo of a snowflake. There's no deeper
meaning than that. I wondered about that for a while until someone told me.

Basically, a ["flake"](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
is a way to define something in Nix that is completely self-contained. All the
inputs are defined explicitly in the `inputs` field, and these are locked to a
specific git commit or hash of some sort. In regular Nix, you have to declare
all these hashes yourself, which is painful. Flakes are marked as "experimental"
still, but really are quite widespread and generally accepted as "the way" now.

The output of a flake can be a number of things. In our particular case, we're
defining an output that's being used by `home-manager` to define our user space
environment. In other cases we can define things like packages, entire system
configurations of NixOS, or even just a single function or library of functions.
For now, we just care that we're creating a home-manager configuration. In the
future, specific commands may look for different output fields.

When you build or use a flake, it will try and reference the `flake.lock` file.
If it doesn't exist, it will generate the lock file by getting the latest
versions of the defined inputs. If inputs are added, they will be saved
automatically to the `flake.lock` file. If inputs are removed, they will be
automatically removed from `flake.lock`. They are never automatically updated,
to preserve reproducibility, but can be explicitly [updated with a Nix command.](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake-update.html)

## Anatomy of a flake

Let's look at the flake we made, one section at a time.

### The curly brackets

Yes, the curly brackets. We're starting there.

```nix
{
  # Why is this in curly brackets?
}
```

In Nix, every `*.nix` file is a single [_Nix expression_](https://nixos.org/manual/nix/stable/language/).
In this case, we're defining a [_Nix attribute set_](https://nixos.org/manual/nix/stable/language/values.html#attribute-set).
A Nix attribute set is basically a dictionary object, like a JSON blob. It
contains some number of fields, which hold some number of expression values.

An attribute set is defined by curly brackets. The fields can be any
alphanumeric value and may include dashes, undescores, or apostrophes. They
often hold attribute sets of their own, nesting deeply for specific
configurations.

You will see these absolutely everywhere. They are the bread and butter of Nix.

### Top level fields in a flake

There are a few top level fields of a flake that we need to worry about. They
are specifically `description`, `inputs`, and `outputs`.

`description` is a string that describes the flake. Optional.

`inputs` is a set of inputs that the flake uses. A flake only ever sees what's
in `inputs` and what's been explicitly added in the local git repository.

`outputs` is a function that takes all of the defined `inputs` and produces
some configuration we're interested in.

### The description

```nix
{
  description = "My Home Manager configuration";
}
```

Here's a field called `description` that holds a string literal. As simple as
it gets. Notice that it must end in a semicolon. All assignments in an
attribute set in Nix must end in a semicolon. This means that whitespace doesn't
really matter.

```nix
{
  # Also fine!
  description =
    "My Home Manager configuration";
}
```

Where is this used? You can run `nix flake info` to see it, but honestly
it's optional. I'm just including it here because it's a convenient way to
show a simple string value assignment! In fact, if you look at the root
[flake.nix](./flake.nix) file, you'll see that there's no description field
defined at all. It's more useful in a shareable package, so for your home
manager setup you can omit it if you want.

### The inputs

Now we get to something a little more interesting.

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

You should recognize by now that `inputs` is being set to a Nix attribute set.
Inside `inputs` we have two fields: `nixpkgs` and `home-manager`.

But hold on, what's this `nixpkgs.url` thing?

```nix
{
  # Exactly the same as below
  nixpkgs = {
    url = "nixpkgs/nixos-23.11";
  };

  # Totally the same!
  nixpkgs.url = "nixpkgs/nixos-23.11";
}
```

Using the `.` is just a shortcut for a nested field in a deeper attribute set.
So you can recognize now that each value in `inputs` is itself a new attribute
set that usually contains a `url` at minimum. This `url` field is often a
github link, but it can be set to other things as well.

Note that if you use this `.` shortcut, you can use it multiple times or at any
point in the nesting. It will all combine as you'd expect:

```nix
{
  # The same as what we have in our flake!
  home-manager.url = "github:nix-community/home-manager/release-23.11";
  home-manager.inputs.nixpkgs.follows = "nixpkgs";

  # Also the same!
  home-manager = {
    url = "github:nix-community/home-manager/release-23.11";
    inputs = {
      nixpkgs = {
        follows = "nixpkgs";
      };
    };
  };
}
```

The actual names of `nixpkgs` and `home-manager` are arbitrary. They could be
whatever you want them to be, but it's common to use these names so best to
stick with tradition.

Looking at the `home-manager` input, you can see that it has a field called
`inputs.nixpkgs.follows`. This is a way to say that the `home-manager` input
depends on the `nixpkgs` input.

For a reference on what other things can be in the `inputs` field, see the
[official docs](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html#flake-inputs).
However, you'll generally not want to mess with this too much early on, so as
long as you're comfortable understanding that the two inputs we have here are
Github repositories we're locking to, then you're fine to move on.

#### `nixpkgs`

`nixpkgs` is a bit special. It's a reference to the [Nixpkgs repository](https://github.com/NixOS/nixpkgs),
which contains over 80,000 packages. It's so special it gets its own import
without needing any github information. The `23.11` part is a git tag. You can
[see it here](https://github.com/NixOS/nixpkgs/releases/tag/23.11) if you're
curious. There's nothing special about it otherwise, it's just a tag to freeze
all the packages at a specific version. You can use other tags, provide a
specific git commit SHA, or even go `unstable` if you want to get the latest
(remember it will still be locked to whatever the 'latest' was at the time of
the first apply!)

It's not just packages, though! It contains an [extensive standard library](https://nixos.org/manual/nixpkgs/stable/#sec-functions-library)
of sorts for Nix, located in `nixpkgs/lib`. If you really want a rabbit hole,
[check the source here](https://github.com/NixOS/nixpkgs/tree/master/lib).

Basically, `nixpkgs` is probably the absolute most important input you'll ever
include, and you'll probably include it in every single flake you ever make.

## Summary so far

Ok, that's already a lot and we haven't even gotten past `inputs`! Let's take
a break and make sure we understand what's going on so far, because the
`outputs` section is going to be even more complicated.

You should have a general understanding of the following. If you don't, go back
and reread.

- What a flake is (basically)
- What `inputs` are and how they're defined (basically)
- Some basic Nix syntax
  - A Nix attribute set is some key/values in curly brackets
  - String literals in Nix
  - `thing.another.stuff = "value";` as a shortcut

If you're feeling good, let's move on to [the outputs section](./04-explain-outputs-function.md).
