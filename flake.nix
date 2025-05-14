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
        packages = {
          default = self.packages.${system}.claude-wrapper;

          claude-wrapper = pkgs.buildNpmPackage {
            pname = "claude-wrapper";
            version = "0.1.10";

            # This is where the package.json and bin/claude.js files will live
            src = ./.;

            npmDepsHash = "sha256-Hw56ZW6KUbJUQAVi8GRuoRCEXmbaPEgNW0PPj9rAHak=";

            # Install phase
            installPhase = ''
              runHook preInstall

              echo "Installing $pname $version"

              mkdir -p $out/bin
              mkdir -p $out/lib/node_modules/claude-wrapper

              cp -r ./* $out/lib/node_modules/claude-wrapper/

              # Make sure the binaries are executable
              chmod +x $out/lib/node_modules/claude-wrapper/bin/claude.js
              chmod +x $out/lib/node_modules/claude-wrapper/bin/mcp-remote.js
              chmod +x $out/lib/node_modules/claude-wrapper/bin/mcp-remote-client.js

              # Create symlinks to the binaries
              ln -s $out/lib/node_modules/claude-wrapper/bin/claude.js $out/bin/claude
              ln -s $out/lib/node_modules/claude-wrapper/bin/mcp-remote.js $out/bin/mcp-remote
              ln -s $out/lib/node_modules/claude-wrapper/bin/mcp-remote-client.js $out/bin/mcp-remote-client

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
        };

        apps = {
          default = self.apps.${system}.claude;

          claude = flake-utils.lib.mkApp {
            drv = self.packages.${system}.claude-wrapper;
            name = "claude";
          };

          mcp-remote = flake-utils.lib.mkApp {
            drv = self.packages.${system}.claude-wrapper;
            name = "mcp-remote";
          };

          mcp-remote-client = flake-utils.lib.mkApp {
            drv = self.packages.${system}.claude-wrapper;
            name = "mcp-remote-client";
          };
        };
      }
    );
}
