{ pkgs, ... }:

{
  imports = [
    ../desktop/ghostty-linux.nix
    ../desktop/niri.nix
    ../desktop/quickshell.nix
    ../desktop/rofi.nix
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
    niri
    xwayland-satellite
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    grim
    slurp
    wl-clipboard
    pavucontrol
    papirus-icon-theme
    matugen
    cava
    toolbox
    qt5.qtquickcontrols2
    qt6.qtdeclarative
    qt6.qtsvg
  ];
}
