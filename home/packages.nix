{config, pkgs, ...}:
{
  home.packages = [
    pkgs.ripgrep #nvim telescope
    pkgs.nodePackages.bash-language-server #neovim bash LSP
  ];
}
