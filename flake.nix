{
  description = "NixOS vm DEV";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    #second nixpkgs for darwin systems, likely to match above unless broken package
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let

      ssh-key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBH3DrOvocMoywlG0SZYhrkv7E9dx3uZSRWTlg0rDOXfCyU+3Ynue+ufGhXjU1+vI3axnEtWiompq75U2XhwRdmQ= ";
      username = "charper";

      nixos-ptr = {
        home = home-manager.nixosModules.home-manager;
        system = nixpkgs.lib.nixosSystem;
      };

      darwin-ptr = {
        home = home-manager.darwinModules.home-manager;
        system = nix-darwin.lib.darwinSystem;
      };

      mksystemConfig =
        { system, system-name, ptr, ... }:
        let
          extraArgs = { inherit ssh-key username system-name; };
        in
        ptr.system {
          specialArgs = extraArgs;
          inherit system;
          modules =
            [
              ./hosts/${system-name}
              ptr.home
              {
                home-manager.extraSpecialArgs = extraArgs;
                home-manager.useUserPackages = true;
                home-manager.useGlobalPkgs = true;
                home-manager.users.${username} = {
                  imports =
                    [
                      ./home/${username}/${system-name}.nix
                      ./home/${username}/shell.nix
                      ./home/${username}/packages.nix
                      ./home/${username}/git.nix
                      ./home/${username}/tmux.nix
                      ./home/${username}/neovim.nix
                    ];
                };
              }
            ];
        };
    in
    {
      darwinConfigurations = {
        darwin-m1air = mksystemConfig {
          system = "aarch64-darwin";
          system-name = "darwin-m1air";
          ptr = darwin-ptr;
        };
      };
      nixosConfigurations = {
        nixos-vmware = mksystemConfig {
          system = "aarch64-linux";
          system-name = "nixos-vmware";
          ptr = nixos-ptr;
        };
      };
    };
}
