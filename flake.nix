{
  description = "NixOS vm DEV";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";

    #second nixpkgs for darwin systems, likely to match above unless broken package
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";

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

    ssh-key = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBH3DrOvocMoywlG0SZYhrkv7E9dx3uZSRWTlg0rDOXfCyU+3Ynue+ufGhXjU1+vI3axnEtWiompq75U2XhwRdmQ= ";
    username = "charper";

    mksystemConfig = 
    system-name: { system ,
      isDarwin ? nixpkgs.lib.hasSuffix "-darwin" system ,
      ...
    }:let 
        extraArgs = {inherit ssh-key username system-name;};
      in
    (if isDarwin
      then nix-darwin.lib.darwinSystem
      else nixpkgs.lib.nixosSystem
    ){
      specialArgs = extraArgs;
      inherit system;
      modules = 
        [./hosts/${system-name}]
        ++ [

          ( 
            if isDarwin
            then home-manager.darwinModules.home-manager
            else home-manager.nixosModules.home-manager
          ){

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
  in {
    darwinConfigurations = {
      darwin-m1air = mksystemConfig "darwin-m1air" {
        system = "aarch64-darwin";
      };
    };
    nixosConfigurations = {
      nixos-vmware = mksystemConfig "nixos-vmware" {
        system = "aarch64-linux";
      };
    };
  };
}
