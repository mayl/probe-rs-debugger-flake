{
  description = "probe-rs-debugger";

  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = {
          probe-rs-debugger = pkgs.callPackage ./probe-rs-debugger.nix { buildFromSrc = false; };
          default = self.packages.${system}.probe-rs-debugger;
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            (pkgs.vscode-with-extensions.override {
              vscodeExtensions = [ self.packages.${system}.probe-rs-debugger ];
            })
          ];
        };
      }
    );
}
