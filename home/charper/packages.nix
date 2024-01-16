{ pkgs, ... }:
{
  home.packages = [
    pkgs.git
    pkgs.ripgrep #neovim telescope
    pkgs.nodePackages.bash-language-server #neovim bash LSP
    pkgs.nil # neovim nix LSP

    # https://github.com/nix-community/fenix
    (pkgs.fenix.stable.withComponents[
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    pkgs.rust-analyzer-nightly

  ];
}
