# Make a basic repository with a simple flake

## What's a fla-

Don't care, move on, find out later.

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

  # This needs to actually be set to your username
  username = "myusername";

  home.stateVersion = "23.11";
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
# Careful about copy/pasting, Makefiles want tabs!
.PHONY: update
update:
    home-manager switch --flake .#myusername
```

Change `myusername` to whatever you changed it to in `flake.nix`. This is how
we can target different profiles in the future.

## Activate home-manager

### Trip on a rake first

```bash
# THIS WILL ERROR.  IT WILL MAKE NO SENSE.  Read below.
make
```

Assuming you aren't an overachiever and did only what I asked you to do, you
should see an error about the files not being found. But the files are there.
I know that. You know that. Why doesn't Nix know that?

First explanation, because it will bite you: Nix with flakes will **completely
ignore** anything that isn't added to the git repository. This is actually a
good thing, I promise. Because everything must be in the git repository, you
will be guaranteed that everything is reproducible. So to fix it, we just need
to add everything to git. If you already did this out of habit, you may have
already seen everything work.

### Actually activate it

```bash
# Add everything to git
git add flake.nix home.nix Makefile
# Technically not necessary to commit, we only need to add, but still
git commit -m "First home-manager commit"

# This should work now
make

# Now we should be able to run hello!
hello
```

If `hello` isn't found, make sure you followed the install steps correctly. In
particular, make sure you're sourcing the file they told you to source!

If `hello` is found and you see output, congratulations! You have Home Manager
with flakes, and you hopefully did it a lot faster than I did.

## Your first tinkering

You can start adding more packages from
[NixOS packages](https://search.nixos.org/packages) if you want. Try adding a
few and run `make` again to get access to them in your shell. To add a package,
just add the name with some whitespace. Like so:

```nix
{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    hello
    # Doesn't matter if they're on new lines or not
    cowsay lolcat
  ];

  # This needs to actually be set to your username
  username = "myusername";

  # Don't ever change this after the first build.  Don't ask questions.
  home.stateVersion = "23.11";
}
```

You can also remove packages. Try removing `hello` from `home.nix` and notice
that you can no longer run `hello` from your shell.

You also just learned about Nix lists! Nix lists are just space-separated
items. Any amount of whitespace is fine. They don't like commas.

## A cleanup step

Before we're done, we really should add a cleanup task to our Makefile. This
will make sure that Nix isn't eating your disk over a long period of time with
lots of changes.

```make
# Careful about copy/pasting, Makefiles want tabs!
.PHONY: update
update:
    home-manager switch --flake .#myusername

.PHONY: clean
clean:
    nix-collect-garbage -d
```

Nix will only clean up after itself when told to, because it purposefully keeps
older generations for rollbacks. Don't worry about that for now, just know that
you need to run `make clean` from time to time. This particular command will
remove older generations, for the record.

## Troubleshooting

If anything is still broken, compare your files with
[./02-basic-repository-setup.md](./02-basic-repository-setup.md) and make sure
you didn't miss anything.

## Summary

We added a flake.nix file to define a user profile, a home.nix file that defines
the configuration of the user profile, and a Makefile to make it easy to switch.

You can now add packages to your user profile, and remove them.

You can clean up after yourself with `make clean`.

## Next steps

From here, the Nix world opens up and you can start doing all sorts of fun
things by modifying your `home.nix`.

In the future, we'll talk about how to find interesting/useful configuration
options to do things like
[manage your bashrc](https://mynixos.com/home-manager/options/programs.bash),
how to organize your `home.nix` into separate module files with your own
configuration options, and more.

_TODO: Actually write that part._
