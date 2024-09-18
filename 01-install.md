# 01 - Install Nix and Home Manager

[<- README.md](README.md) | [02 - Basic repository setup ->](02-basic-repository-setup.md)

## Install Nix

[Install Nix](https://nixos.org/download.html).

You probably want the multi-user installation, unless you really hate the idea
of running anything as root.

You may be tempted to start digging into random documentation here. Don't.
Save that for another day.

### Enable Flakes

You want to enable flakes. Why? Look into that later.

For now just put this in `~/.config/nix/nix.conf` or
[wherever your Nix config is](https://nixos.wiki/wiki/Flakes):

```
experimental-features = nix-command flakes
```

You should at least be aware that they are NOT guaranteed to be stable, but this
is fine for a personal setup. When you're ready to dig into that more,
[check out the official page here](https://nix.dev/concepts/flakes). For now,
just know that they're great and you want them and that they may change a bit
in the future so just be aware.

### Make sure it works

Can you run this?

```bash
nix run nixpkgs#hello
```

Yes? Great. You have Nix with flakes enabled.

What was that syntax? What's `nixpkgs`? Don't worry about it, move on, look at
it later.

## Install Home Manager

[Install Home Manager](https://nix-community.github.io/home-manager/index.xhtml#ch-installation).

If you're here reading this, you want the standalone. If you're on NixOS,
install it as a [package via NixOS](https://search.nixos.org/packages?show=home-manager&query=home-manager).

Make sure you follow step 4:

```bash
# This must be sourced in your .bashrc or whatever shell you're using.
# In the future we can get home-manager to do this for us, but bootstrapping for now...
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
```

Do not read the rest of the docs. Do not try the getting started bits. Do not
look for reason or explanation. Stay with me, you can go back once you have
something working.

### Make sure it works

Can you run this?

```bash
home-manager --version
```

Yes? Great. You have Home Manager.

[Onto the next!](02-basic-repository-setup.md)
