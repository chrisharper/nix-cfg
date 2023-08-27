{
  description = "NixOS vm DEV";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    home-manager = {
      url = github:nix-community/home-manager/release-23.05;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{nix-darwin, nixpkgs, home-manager,  ... }:
  let 
    ssh-key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBH3DrOvocMoywlG0SZYhrkv7E9dx3uZSRWTlg0rDOXfCyU+3Ynue+ufGhXjU1+vI3axnEtWiompq75U2XhwRdmQ= ";
  in {
    darwinConfigurations = {
      darwin-m1air = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit ssh-key; };
        system = "aarch64-darwin";
        modules = [
          ./hosts/darwin-m1air
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit ssh-key; };
              useUserPackages = true;
              useGlobalPkgs = true;
              users.charper = import ./hosts/darwin-m1air/home.nix;
            };
          }
        ];
      };
    };
    nixosConfigurations = {
      nixos-vmware = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit ssh-key; };
        modules = [
          ./hosts/nixos-vmware
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              extraSpecialArgs = { inherit ssh-key; };
              useUserPackages = true;
              useGlobalPkgs = true;
              users.charper = import ./hosts/nixos-vmware/home.nix;
            };
          }
        ];
      };
    };
  };
}
