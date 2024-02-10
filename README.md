# Simple start with Nix Home Manager with Flakes

**Do not click around. Read this guide in order. Do all the steps. You'll thank
me later.**

Want to control your entire Linux user space in a declarative, highly
configurable, highly reproducible manner that you can take with you from machine
to machine without ever worrying about how to rebuild it? Did you try to do that
with Nix's Home Manager and hated your life? Read on.

## What is this?

I like Nix. A lot. I think you will too. But I hated getting started with it.

The documentation for Nix is a headache to wade through and understand in one
go. Piecing together random blog posts diving into all the flashy fun cool stuff
is painful, and many of them are old/stale. Simple, practical starter guides for
using [home manager](https://github.com/nix-community/home-manager) were
surprisingly difficult to find. Maybe I was just missing them.

Regardless, **this is the guide I wish I had when I started**. All I wanted was
a foundation to start playing with and build on. So here you go: a low-nonsense
guide to getting started with Home Manager with Flakes.

## Start the journey

### Assumptions

I assume you are running Linux of some sort. This may work on Mac too, but I
haven't tried it.

I assume you are NOT running NixOS. If you are, you may want to read a little
more carefully when it comes to installing Home Manager. The easiest way to
install it at that point IMO is just adding it as a package to your NixOS
install. After Home Manager is installed, it should all be the same anyway.

I do not assume you have any experience with Nix.

I assume you have minimal programming knowledge.  If you know what a "string"
and an "array" are, you're probably fine.

### Please read this bit

I am not going to give you deep explanations of why certain things are the way
they are. I am not going to give you fifty different ways to do something. The
rabbit holes of Nix go deep. **Do not stray from the path** until you have
something minimal working, and then I'll show you how to start tinkering. Once
you have some minimal tinkering under your belt, everything else in Nix will
make so much more sense and you can explore all you want!

If you see code, don't copy/paste it. Type it yourself. _Neuroscience_. You'll
learn it a lot quicker that way.

Ok, ready? **[Let's go! (01-install.md)](01-install.md)**.
