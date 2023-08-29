{pkgs, ...}:
{
  home.packages = [
    pkgs.git
    pkgs.ripgrep #neovim telescope
    pkgs.nodePackages.bash-language-server #neovim bash LSP
    pkgs.nil # neovim nix LSP
  ];
}
