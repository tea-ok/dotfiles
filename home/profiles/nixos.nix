{ pkgs, ... }:

{
  imports = [
    ../desktop/ghostty-linux.nix
    ../desktop/niri.nix
    ../desktop/theme.nix
  ];

  home.username = "taavi";
  home.homeDirectory = "/home/taavi";

  home.packages = with pkgs; [
    _1password-gui
    discord
    spotify
    obsidian
    proton-vpn
    xwayland-satellite
    wl-clipboard
    pavucontrol
    papirus-icon-theme
    toolbox
    nixfmt
    nil
    gcc
    grim
    slurp
    libnotify
  ];
}
