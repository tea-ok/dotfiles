{ pkgs, ... }:

{
  home.username = "taavi";
  home.homeDirectory = "/home/taavi";

  home.packages = with pkgs; [
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

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      background-opacity = 0.95;
      window-padding-x = 8;
      window-padding-y = 8;
      background-blur-radius = 5;
      font-size = 13;
      theme = "Catppuccin Frappe";
      command = "/usr/bin/zsh";
      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
      ];
    };
  };

  programs.rofi = {
    enable = true;
    modes = [
      "drun"
      "run"
    ];
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{icon} {name}";
    };
    theme = ../rofi/.config/rofi/themes/spotlight-dark-frappe.rasi;
  };

  programs.quickshell = {
    enable = true;
    package = pkgs.quickshell;
  };

  # /etc/keyd/default.conf still needs to be applied manually with
  # `sudo stow keyd` until this machine moves to NixOS.
  home.file = {
    ".config/ghostty/shaders".source = ../ghostty/.config/ghostty/shaders;
    ".config/ghostty/themes/dankcolors".source = ../ghostty/.config/ghostty/themes/dankcolors;
    ".config/niri".source = ../niri/.config/niri;
    ".config/quickshell".source = ../quickshell/.config/quickshell;
    ".config/DankMaterialShell".source = ../dank/.config/DankMaterialShell;
    ".config/gtk-3.0".source = ../theme/.config/gtk-3.0;
    ".config/gtk-4.0".source = ../theme/.config/gtk-4.0;
    ".config/kdeglobals".source = ../theme/.config/kdeglobals;
    ".local/bin".source = ../local/.local/bin;
    ".local/share/applications".source = ../local/.local/share/applications;
    ".config/rofi/themes/catppuccin-frappe.rasi".source =
      ../rofi/.config/rofi/themes/catppuccin-frappe.rasi;
  };
}
