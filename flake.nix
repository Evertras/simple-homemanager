# Why are you looking at this?  Go back to the README.md!
#
# This is just some quick tooling for formatting.  Ignore it.
# I'm not going to explain it.
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            nixfmt
            nodePackages.prettier
          ];
        };
      }
    );
}
