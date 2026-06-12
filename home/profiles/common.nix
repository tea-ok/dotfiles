{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../programs/ai.nix
    ../programs/cli.nix
    ../programs/editors.nix
    ../programs/migrations.nix
    ../programs/shell.nix
  ];

  home.stateVersion = "26.05";

  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };
  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = with pkgs; [
    rustup
    neovim
    vim
    ripgrep
    fd
    gh
    jq
    uv
    fastfetch
    stylua
    prettier
    markdownlint-cli2
    tree-sitter
    ruff
    ty
    htop
    go
    gopls
    unzip
    nerd-fonts.jetbrains-mono
    zsh-completions
  ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ]
  ++ lib.optional pkgs.stdenv.hostPlatform.isDarwin "/usr/local/go/bin";
}
