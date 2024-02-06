# Install Nix and Home Manager

## Install Nix

[Install Nix](https://nixos.org/download.html).

You probably want the multi-user installation, unless you really hate the idea
of running anything as root.

### Enable Flakes

You want to enable flakes. Why? Look into that later.

For now just put this in `~/.config/nix/nix.conf` or
[wherever your Nix config is](https://nixos.wiki/wiki/Flakes):

```
experimental-features = nix-command flakes
```

It's "experimental" but it's been in use for years and everyone uses them.
Just do it.

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
install it as a [package via NixOS](https://search.nixos.org/packages?channel=23.11&show=home-manager&from=0&size=50&sort=relevance&type=packages&query=home-manager).

Make sure you follow step 4:

```bash
# This must be sourced in your .bashrc or whatever shell you're using.
# In the future we can get home-manager to do this for us, but bootstrapping for now...
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
```

### Make sure it works

Can you run this?

```bash
home-manager --version
```

Yes? Great. You have Home Manager.

[Onto the next!](02-basic-repository-setup.md)
