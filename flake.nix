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
          default = self.packages.${system}.claude-plus-mcp;

          claude-plus-mcp = pkgs.buildNpmPackage {
            pname = "claude-plus-mcp";
            version = "0.2.1";

            # This is where the package.json and bin/claude.js files will live
            src = ./.;

            npmDepsHash = "sha256-2jnbhcMUI+zsZ7auU8xe9ZQBDo2BA/e/u50QB1yqjkU=";

            # Install phase
            installPhase = ''
              runHook preInstall

              echo "Installing $pname $version"

              mkdir -p $out/bin
              mkdir -p $out/lib/node_modules/claude-plus-mcp

              cp -r ./* $out/lib/node_modules/claude-plus-mcp/

              # Make sure the binaries are executable
              chmod +x $out/lib/node_modules/claude-plus-mcp/bin/claude.js
              chmod +x $out/lib/node_modules/claude-plus-mcp/bin/mcp-remote.js
              chmod +x $out/lib/node_modules/claude-plus-mcp/bin/mcp-remote-client.js
              chmod +x $out/lib/node_modules/claude-plus-mcp/bin/slite-mcp-server.js

              # Create symlinks to the binaries
              ln -s $out/lib/node_modules/claude-plus-mcp/bin/claude.js $out/bin/claude
              ln -s $out/lib/node_modules/claude-plus-mcp/bin/mcp-remote.js $out/bin/mcp-remote
              ln -s $out/lib/node_modules/claude-plus-mcp/bin/mcp-remote-client.js $out/bin/mcp-remote-client
              ln -s $out/lib/node_modules/claude-plus-mcp/bin/slite-mcp-server.js $out/bin/slite-mcp-server

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Claude + mcp wrappers";
            };
          };
        };

        apps = {
          default = self.apps.${system}.claude;

          claude = flake-utils.lib.mkApp {
            drv = self.packages.${system}.claude-plus-mcp;
            name = "claude";
          };

          mcp-remote = flake-utils.lib.mkApp {
            drv = self.packages.${system}.claude-plus-mcp;
            name = "mcp-remote";
          };

          mcp-remote-client = flake-utils.lib.mkApp {
            drv = self.packages.${system}.claude-plus-mcp;
            name = "mcp-remote-client";
          };

          slite-mcp-server = flake-utils.lib.mkApp {
            drv = self.packages.${system}.claude-plus-mcp;
            name = "slite-mcp-server";
          };
        };
      }
    );
}
