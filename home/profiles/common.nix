{
  lib,
  pkgs,
  zig-overlay,
  zls,
  ...
}:

{
  imports = [
    ../programs/ai.nix
    ../programs/cli.nix
    ../programs/editors.nix
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
    zig-overlay.packages.${pkgs.stdenv.hostPlatform.system}.master
    zls.packages.${pkgs.stdenv.hostPlatform.system}.zls
    ffmpeg
    kitty
  ];

  home.sessionPath =
    lib.optional pkgs.stdenv.hostPlatform.isLinux "$HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/bin"
    ++ [
      "$HOME/.cargo/bin"
      "$HOME/.local/bin"
      "$HOME/go/bin"
    ]
    ++ lib.optional pkgs.stdenv.hostPlatform.isDarwin "/usr/local/go/bin";
}
