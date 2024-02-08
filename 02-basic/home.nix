{ lib, pkgs, ... }: {
  # Install packages from https://search.nixos.org/packages
  home.packages = with pkgs; [
    # Says hello.  So helpful.
    hello

    # Another package, just to show what a list looks like.
    # Notice there's no commas anywhere.
    cowsay
  ];

  # This needs to be set to your actual username.
  username = "myusername";
  homeDirectory = "/home/myusername";

  # Don't ever change this after the first build.
  # It tells home-manager what the original state schema
  # was, so it knows how to go to the next state.  It
  # should NOT update when you update your system!
  home.stateVersion = "23.11";
}
