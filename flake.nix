{
  description = "Quickly find repositories";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        packages = rec {
          counsel-repo = pkgs.buildGoModule {
            name = "counsel-repo";
            src = ./.;
            vendorHash = null;
          };
          default = counsel-repo;
        };

        apps = rec {
          counsel-repo = flake-utils.lib.mkApp { drv = self.packages.${system}.counsel-repo; };
          default = counsel-repo;
        };
      });
}
