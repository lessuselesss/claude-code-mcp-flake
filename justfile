default:
  nix build .

validate:
  nix run .#claude -- --version
  nix run .#slite-mcp-server -- --version

install:
  nix profile remove claude && nix profile install .

update:
  npm install
  nix build .
  just validate
  just install