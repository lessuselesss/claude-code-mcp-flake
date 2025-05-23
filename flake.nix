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
            version = "0.2.2";

            # This is where the package.json and bin/claude.js files will live
            src = ./.;

            npmDepsHash = "sha256-gG9P0aUSWNVRGSd4huLnVVCOsCBdfZzJvr71R3diq2E=";

            installPhase = ''
              runHook preInstall

              mkdir -p $out/bin $out/share
              cp -r node_modules $out/share/
              
              # Direct symlinks to actual executables
              ln -s $out/share/node_modules/@anthropic-ai/claude-code/cli.js $out/bin/claude
              ln -s $out/share/node_modules/mcp-remote/dist/proxy.js $out/bin/mcp-remote
              ln -s $out/share/node_modules/mcp-remote/dist/client.js $out/bin/mcp-remote-client
              ln -s $out/share/node_modules/slite-mcp-server/build/index.js $out/bin/slite-mcp-server

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
