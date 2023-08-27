{ config, pkgs, ... }:

{
  networking.hostName="m1air";
  homebrew.enable=true;
  homebrew.casks = [
    "vmware-fusion"
    "secretive"
    "kitty"
  ];

  system.defaults.dock.autohide=true;
  system.defaults.dock.minimize-to-application=true;
  system.defaults.dock.static-only=true;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle="Dark";
  system.defaults.spaces.spans-displays=true;

  users.users.charper.home="/Users/charper";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
