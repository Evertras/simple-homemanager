# Make a basic repository with a simple flake

## Init a git repository

You want to make a git repository for your Home Manager config. You want this
because it will be reproducible, versioned, and easily transported across
machines.

```bash
# Call it whatever you want, I won't judge
mkdir my-home-manager
git init
```

## Make a flake.nix

Let's make a simple flake. Why are any of these fields the way they are? What
are inputs? Outputs? Don't worry about it, just do this for now. The only thing
you need to know for now is that this file will define some number of user
profiles and contain information on how to load their configurations.

I know you already want answers. I wanted answers. I was frustrated, trying to
dig into _why_ I was doing these things when I saw them before moving on. That
was a mistake. Trust me, just push through and get something working first.
Then you can get answers, because you can play with it. The rabbit holes are
too deep for now.

That being said, type this out yourself. Don't copy/paste it. It will be
annoying. But doing things the long way will help you remember them. It's a
neuroscience thing, just do it.

```nix
# flake.nix
# Don't copy and paste this.  Read above first if you tried to cheat and skim.
{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {

      homeConfigurations = {
        myusername = {
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./home.nix ];
          }
      };
    };
}
```

When you were typing this (and **NOT** copy/pasting it, don't cheat), did you
see `myusername`? Change that to your actual Linux username, your dog's name,
or your favorite planet. Doesn't matter as long as it's alphanumeric
(`[a-z0-9-]+`), just remember it for later.

## Make a home.nix

I bet you saw that `./home.nix` reference up there. Let's make that file, also
in the root of the repository.

```nix
{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    hello
  ];
}
```

## Checkpoint

Try this before we move on.

```bash
hello
```

If you see an error that `hello` was not found, great! Now we can make sure that
Home Manager is working for you.

## Make a Makefile

I hate writing out commands with flags in them. So let's make a Makefile do all
that work for us before we even try running it.

```make
.PHONY: update
update:
    home-manager switch --flake .#myusername
```

Change `myusername` to whatever you changed it to in `flake.nix`. This is how
we can target different profiles in the future.

## Activate home-manager

```bash
# Runs the home-manager switch command we defined above
make

# Now we should be able to run hello
hello
```

If `hello` isn't found, make sure you followed the install steps correctly. In
particular, make sure you're sourcing the file they told you to source!

If `hello` is found and you see output, congratulations! You have Home Manager
with flakes, and you hopefully did it a lot faster than I did.

TODO: Tinkering
