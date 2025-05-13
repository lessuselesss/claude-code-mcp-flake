default:
  nix build .

install:
  nix profile remove claude && nix profile install .