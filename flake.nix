{
  description = "NixOS vm DEV";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
  };

  outputs = {nixpkgs, nix-darwin, home-manager,  ... }:
  let 
    specialArgs = {
      ssh-key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBH3DrOvocMoywlG0SZYhrkv7E9dx3uZSRWTlg0rDOXfCyU+3Ynue+ufGhXjU1+vI3axnEtWiompq75U2XhwRdmQ= ";
    };
    mksystemConfig = 
    { system ,
      modules,
      hm-modules,
      isDarwin ? nixpkgs.lib.hasSuffix "-darwin" system ,
      ...
    }:(
      if isDarwin
      then nix-darwin.lib.darwinSystem
      else nixpkgs.lib.nixosSystem
    ){
      inherit specialArgs;
      inherit system;
      modules = 
        modules
        ++ [
          ( 
            if isDarwin
            then home-manager.darwinModules.home-manager
            else home-manager.nixosModules.home-manager
          ){

             home-manager.extraSpecialArgs = specialArgs;
             home-manager.useUserPackages = true;
             home-manager.useGlobalPkgs = true;
             home-manager.users.charper = {
               imports = hm-modules
               ++[
                 ./home/shell.nix
                 ./home/packages.nix
                 ./home/git.nix
                 ./home/tmux.nix
                 ./home/neovim.nix
               ];
             };

          }
        ];
    };
  in {
    darwinConfigurations = {
      darwin-m1air = mksystemConfig {
        system = "aarch64-darwin";
        modules = [./hosts/darwin-m1air];
        hm-modules = [./home/darwin.nix];
      };
    };
    nixosConfigurations = {
      nixos-vmware = mksystemConfig {
        system = "aarch64-linux";
        modules = [./hosts/nixos-vmware];
        hm-modules = [./home/nixos.nix];
      };
    };
  };
}
