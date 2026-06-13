{ pkgs, ... }:

let
  screenshotSnipDesktop = pkgs.makeDesktopItem {
    name = "screenshot-snip";
    desktopName = "Screenshot Snip";
    comment = "Drag to capture a region of the screen";
    exec = "/home/taavi/.local/bin/screenshot-snip";
    icon = "applets-screenshooter";
    terminal = false;
    categories = [
      "Graphics"
      "Utility"
    ];
    keywords = [
      "screenshot"
      "snip"
      "capture"
      "screen"
    ];
  };
in
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
    screenshotSnipDesktop
    davinci-resolve
  ];
}
