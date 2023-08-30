{ username, ... }:

{
  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
  home.username = username;
  home.homeDirectory = "/home/${username}";
}
