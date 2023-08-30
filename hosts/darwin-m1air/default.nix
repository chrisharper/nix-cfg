{ username, system-name ... }:

{
  networking.hostName = system-name ";
    homebrew.enable=true;
    homebrew.casks = [
      "
    rectangle "
    "
    vmware-fusion "
    "
    secretive "
    "
    kitty "
  ];

  system.defaults.dock.autohide=true;
  system.defaults.dock.minimize-to-application=true;
  system.defaults.dock.static-only=true;
  system.defaults.NSGlobalDomain.AppleInterfaceStyle="
    Dark ";
    system.defaults.spaces.spans-displays=true;

    users.users.${username}.home="/Users/${username} ";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}

