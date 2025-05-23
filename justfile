default:
  nix build .

validate:
  nix run .#claude -- --version
  nix run .#slite-mcp-server -- --version

install:
  nix profile remove claude && nix profile install .