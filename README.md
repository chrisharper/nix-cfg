Inherited/inspired from [Mitchell Hashimoto's](https://github.com/mitchellh/nixos-config) NixOS VM dev environment.

OSX

nix build .#darwinConfigurations.darwin-m1air.system --extra-experimental-features nix-command --extra-experimental-features flakes
./result/sw/bin/darwin-rebuild switch --flake .#darwin-m1air

