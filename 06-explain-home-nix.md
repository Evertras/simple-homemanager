# 06 - Explanation: Home.nix

[<- Explanation: Flake.nix output function body](05-explain-outputs-body.md)

In the last section we completed our explanation of the `flake.nix` file. You
should now understand the following:

```nix
# For reference
myprofile = home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [ ./home.nix ];
}
```

- Your profile is the result of a function call of `home-manager.lib.homeManagerConfiguration`
- We passed in a single argument to this function
  - The `pkgs` attribute is from `nixpkgs` and contains all 64 bit linux packages
  - The `modules` attribute is a list that (in this case) contains a single value, which is a path
    - That path is our `home.nix` file

Note that we could provide multiple "modules" here, but for now we have a single
entry point.

## What's a module?

So what even _IS_ a module? Basically, it's a self-contained single function
that takes some inputs and produces some outputs. Specifically, it takes an
attribute set of inputs that contains things like `pkgs` and then produces an
attribute set of outputs that contains things like a list of packages to install
or configuration files to create, which is then processed by some tool like
NixOS or Home Manager to do some useful thing.

## Anatomy of home.nix

That's a lot of words at this point, so let's look at our `home.nix` file,
which is itself a module.

```nix
{ lib, pkgs, ... }: {
  home = {
    packages = with pkgs; [
      hello
      cowsay
    ];

    username = "myusername";
    homeDirectory = "/home/myusername";

    stateVersion = "23.11";
  };
}
```

Most of this syntax should all be familiar to you, except for the `with`. We'll
come back to that later.

First, let's check on some overall structure. Remember that every Nix file needs
to be a single expression, which we [explained back in the first explanatory section](./03-explain-inputs.md)?
In this case, the single expression of this file is a function. This function
takes a single argument, which is an attribute set.

```nix
# Single argument, an attribute set
# vvvvvvvvvvvvvvvvvv
  { lib, pkgs, ... }: #...
#                   ^ The : means it's a function
```

Recall as well from our earlier explanation that this argument must be an
attribute set that contains `lib` and `pkgs`. The `...` means we may get some
other arguments and that's okay, we just don't care about them because we're
~~terrible people~~ efficient power users.

Where do `lib` and `pkgs` come from? They're provided by the module system.
You'll also see `config`, which we'll use later. You can also [pass in your own
special arguments](https://discourse.nixos.org/t/pass-specialargs-to-the-home-manager-module/33068),
but that's outside the scope of this guide.

Ok, so it's a function. What does it return? If you said "another attribute set",
you're getting the hang of Nix! It's always another attribute set.

What's in the attribute set? We have a top level `home` attribute, which then
contains `packages`, `username`, `homeDirectory`, and `stateVersion`. We'll
get into these in a moment.

Note that a module basically runs in two "modes". The first is the simpler way
where the top level attributes are just values that are used for configuration,
like we have here. The other is separating out the top level attributes into
a new attribute set assigned to `config`, and then providing some `options`
definitions that are can be used to modify the module as a whole. The majority
of the modules you write will probably be the second way, which we'll get to,
but I wanted to show this first way because it's simpler and now you'll
recognize it if you see it in the wild instead of wondering where `config` is.

So basically: a module is a file that contains a function. That function
takes a single argument (as all Nix functions do). The argument is an attribute
set which contains some number of inputs that are provided by the module system.
The output is an attribute set that contains some configuration values.

For more information and much deeper dives:

- [NixOS manual on modules](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [nix.dev tutorial on modules](https://nix.dev/tutorials/module-system/module-system.html)

## The `with` keyword

There's one new thing in this file that we haven't seen before: the `with`
keyword.

```nix
{ lib, pkgs, ... }: {
  home = {
    # ... other stuff ...
    packages = with pkgs; [
      hello
      cowsay
    ];
  };
}
```

The simple version is that `with` just tells Nix that for any variable being
used in the following expression, if it's not declared already, check whatever's
in `with`.

For an even simpler version, here's another way to write the same thing
as above, just without the `with`:

```nix
{ lib, pkgs, ... }: {
  home = {
    # ... other stuff ...
    packages = [
      pkgs.hello
      pkgs.cowsay
    ];
  };
}
```

You can hopefully see how this is useful when you have a large number of
`something.x` an `something.y` in an expression. Ok, finally we get to the
good stuff.

## What can go in home.nix?

Congratulations on coming this far. This is where the fun actually begins.
[Welcome to your new candy store at MyNixOS](https://mynixos.com/home-manager/options).

The link above is specifically to all the top level options that are available
in Home Manager. If you look at the list you'll see [`home`](https://mynixos.com/home-manager/options/home).
Then if you follow that, you'll see all the options we can specify in the `home`
attribute. Looking through this list, you'll see [`packages`](https://mynixos.com/home-manager/option/home.packages).

Take a moment to explore this site to look up the other `home` values we've set:
`username`, `homeDirectory`, and `stateVersion`. I'll wait.

The one confusing one is likely `stateVersion`. This one's likely going to be
a little magical for a bit, but the basic idea is that it locks the whole setup
to a specific schema so that the tool knows how to interpret it. This way new
changes can be made to the overall system without breaking older setups. The
short version as a practical day-to-day user: set it and then never, ever change
it or even look at it again.

Did you find the others? Great, let's look at what other fun things we can do.

## Adding a file to your home directory

Let's start with something simple that shouldn't break anything in your existing
setup, but will show you the potential of where this is going. Let's add...
_a file_. Innovation.

Before we start, I want to make something clear: in the long run, you actually
probably won't use this very often. You'll want to prefer using specific
configuration options that will generate config files, or using other
functionality to build shell scripts, etc. However, it's very easy to get
started with this, and it can be useful for sketching out some ideas or just
getting a file somewhere that you want it. Mostly it's a great excuse to show
you some more new syntax.

### Get a file there in the first place

First, [check the docs here](https://mynixos.com/home-manager/options/home.file.%3Cname%3E)
to reference what we're about to do. Specifically, we're interested in the
`text` field to get started. We could also use `source` to copy a complicated
file, but we'll use `text` because it's simpler and we can start doing more
interesting templating in a moment.

I'll skip to the good stuff and give you a working starting point. Then we're
going to make this more interesting.

```nix
{ lib, pkgs, ... }: {
  home = {
    # ... other stuff ...
    file = {
      "hello.txt".text = "Hello, world!";
    };
  };
}
```

Notice this `"hello.txt"` acts as the `<name>` in the documentation. Also recall
that we could do this too:

```nix
"hello.txt" = {
    text = "Hello, world!";
};
```

When you apply this change, you should now be able to do the following:

```bash
cat ~/hello.txt
```

And you should see your `Hello, world!` text!

So what is this file? If you do `ls -l ~/hello.txt` you'll see that it's a
link to a file in `/nix/store`, and it's read-only. You cannot edit this file
(or at least, you shouldn't), unless you edit your home manager setup.

Congratulations, you've made a text file. Now let's make it an _interesting_
text file.

### Making the file into a script

So what's an interesting text file? How about a script that greets us? Let's
use the [`executable` option](https://mynixos.com/home-manager/option/home.file.%3Cname%3E.executable)
to make it something we can run.

```nix
{ lib, pkgs, ... }: {
  home = {
    # ... other stuff ...
    file = {
      "hello.txt" = {
        text = "echo 'Hello, world!'";
        executable = true;
      };
    };
  };
}
```

_Again, this is NOT actually the long term solution you want for writing your
own utility scripts. The long term solution you want is probably
[`writeShellApplication`](https://ryantm.github.io/nixpkgs/builders/trivial-builders/#trivial-builder-writeShellApplication)
in nixpkgs, which is available in `pkgs.writeShellApplication`. This requires
some significant extra work and understanding, so bookmark this later and return
to it once you're more comfortable with Nix generally. If you want a taste of
what this might look like, [here's what I do to generate a bunch of helpful
wrapper scripts in my own setup](https://github.com/Evertras/nix-systems/blob/main/home/modules/shell/funcs/default.nix)._

With that in mind, let's apply our change and see what we've done.

```bash
# Notice it's now marked as executable
ls -l ~/hello.txt

# And as expected, we can run it directly!
~/hello.txt
```

### Multiline strings

Ok, cool... but what if we want to run more than a single command? How do we
do new lines in our script? [We use `''` notation](https://nixos.org/manual/nix/stable/language/values.html#type-string)!

```nix
{ lib, pkgs, ... }: {
  home = {
    # ... other stuff ...
    file = {
      "hello.txt" = {
        text = ''
          #!/usr/bin/env bash

          echo "Hello, world!"
          echo '*slaps roof* This script can fit so many lines in it'
        '';
        executable = true;
      };
    };
  };
}
```

The `''` notation allows us to just write as many lines as we want, and it will
match the leftmost indentation to move everything over as you would expect.

Once again, apply the changes and run it to see that it echos both lines. You
can also `cat ~/hello.txt` to see that it's all there.

### Using variables and string interpolation

Remember how I said Nix isn't just glorified JSON? Let's prove it by adding
something more dynamic to our script.

First, let's extract our username into a variable. If you thought about `let in`
notation, good job!

While we're here, we'll notice that our [home directory](https://mynixos.com/home-manager/option/home.homeDirectory)
has our username hardcoded in. We'll also notice that we probably don't need
to explicitly set the [`homeDirectory` variable](https://mynixos.com/home-manager/option/home.homeDirectory),
but that it's an excellent excuse to look at how to use variables inside
strings.

Basically, `"my string has ${thing} in it"` will inject the value of `thing`
into the string. We can also do simple string combining with `"my string has " + thing + " in it"`.

Let's see how we can use this for our home directory.

```nix
# We could use 'let in' before any expression, but we want the username to be
# available at a high level so we'll put it here.
{ lib, pkgs, ... }: let
  username = "myusername";
in {
  home = {
    # ... other stuff ...
    # Did you think you were escaping 'inherit'?  It's baaaack... remember
    # that this is just "username = username;"
    inherit username;

    # Inject the user name into the home directory
    homeDirectory = "/home/${username}";

    # Note we could also do this, but using direct interpolation
    # looks a lot cleaner once we do anything complicated.
    # homeDirectory = "/home/" + username;
  };
}
```

This also works for our script.

```nix
{ lib, pkgs, ... }: let
  username = "myusername";
in {
  home = {
    # ... other stuff ...
    file = {
      "hello.txt" = {
        text = ''
          #!/usr/bin/env bash

          echo "Hello, ${username}!"
          echo '*slaps roof* This script can fit so many lines in it'
        '';
        executable = true;
      };
    };
  };
}
```

At this point you should be getting _ideas_. Think about all your configuration
files, your bashrc, your zshrc, your vimrc, your emacs config, your gitconfig,
~~your tax returns~~, everything that you keep tweaking and having to copy around
everywhere. Now imagine generating those files, supplying inputs to change
them in a type safe, reproducible way to the point that you can bring up a fresh
VM and just running `make` to have everything exactly the way you want it.

You may not do it with `home.file` in the end, but you should start getting
a sense of the power of Nix!

## Where to go from here

At this point, you should have a basic understanding of what a 'module' is,
where to find some home manager options, and how to set them. You also learned
some new Nix syntax using `with`, multiline strings, and string interpolation.

When I get time, I'd like to write a section on how to start splitting up your
configuration into multiple modules. If you want a head start, check out the
`imports` attribute and realize that modules can import other modules which
can import other modules and so on.

Before you start writing everything in `home.file`, remember that there's almost
always a better way built into Nix to do what you're probably trying to do.
As an example, check out [bash](https://mynixos.com/home-manager/options/programs.bash)
and try to enable Home Manager to manage your bashrc. You can start adding
things like bash aliases, functions, and environment variables.

The important thing is that at this point, you should have a working Home
Manager setup and the basic ability to start experimenting with it yourself.
As time goes on you'll develop your own setup in a way that makes sense to you,
that you can build on and maintain.

Enjoy Nix!
