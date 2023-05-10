{
  description = "Quickly find repositories";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
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
            vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
          };
          default = counsel-repo;
        };

        apps = rec {
          counsel-repo = flake-utils.lib.mkApp { drv = self.packages.${system}.counsel-repo; };
          default = counsel-repo;
        };
      });
}
