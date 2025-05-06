{
  description = "Wrapper for Anthropic Claude Code CLI tool";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
          ];
        };
        packages.default = pkgs.buildNpmPackage {
          pname = "claude-wrapper";
          version = "0.2.102";

          # This is where the package.json and bin/claude.js files will live
          src = ./.;

          npmDepsHash = "sha256-G/a5PRXZ+Zy8aTy1PNt2RCE0Iz3D6CtGc+0U90vUDG0=";

          # Install phase
          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin
            mkdir -p $out/lib/node_modules/claude-wrapper

            cp -r ./* $out/lib/node_modules/claude-wrapper/

            # Make sure the binary is executable
            chmod +x $out/lib/node_modules/claude-wrapper/bin/claude.js

            # Create symlink to the binary
            ln -s $out/lib/node_modules/claude-wrapper/bin/claude.js $out/bin/claude

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "Command-line tool for Anthropic's Claude AI";
            homepage = "https://www.anthropic.com/claude-code";
            license = licenses.mit;
            platforms = platforms.all;
            maintainers = [ ];
          };
        };

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.default;
          name = "claude";
        };
      }
    );
}
