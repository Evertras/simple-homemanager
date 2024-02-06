{ lib, pkgs, ... }: {
  # Install packages from https://search.nixos.org/packages
  home.packages = with pkgs; [
    # Says hello.  So helpful.
    hello

    # Another package, just to show what a list looks like.
    # Notice there's no commas anywhere.
    cowsay
  ];
}
