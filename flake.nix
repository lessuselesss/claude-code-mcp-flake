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
        
        # Define executables and their paths in node_modules
        executables = {
          claude = "@anthropic-ai/claude-code/cli.js";
          mcp-remote = "mcp-remote/dist/proxy.js";
          mcp-remote-client = "mcp-remote/dist/client.js";
          slite-mcp-server = "slite-mcp-server/build/index.js";
        };
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
              
              # Create symlinks for all executables
              ${pkgs.lib.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: path: 
                "ln -s $out/share/node_modules/${path} $out/bin/${name}"
              ) executables)}

              runHook postInstall
            '';

            meta = with pkgs.lib; {
              description = "Claude + mcp wrappers";
            };
          };
        };

        apps = {
          default = self.apps.${system}.claude;
        } // (pkgs.lib.mapAttrs (name: _: flake-utils.lib.mkApp {
          drv = self.packages.${system}.claude-plus-mcp;
          name = name;
        }) executables);
      }
    );
}
