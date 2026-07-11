{
  caelestia-shell,
  config,
  pkgs,
  ...
}:

let
  cursorSize = 24;
  cursorTheme = "Bibata-Modern-Classic";

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
    caelestia-shell.homeManagerModules.default
    ../desktop/ghostty-linux.nix
    ../desktop/kitty.nix
    ../desktop/theme.nix
  ];

  home.username = "taavi";
  home.homeDirectory = "/home/taavi";

  home.sessionVariables.BROWSER = "firefox";

  home.packages = with pkgs; [
    _1password-gui
    vesktop
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
    hyprcursor
    brightnessctl
    playerctl
    libnotify
    screenshotSnipDesktop
    davinci-resolve
    kitty
    protonmail-desktop
    prismlauncher
    brave
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        firefox = [ "firefox.desktop" ];
      in
      {
        "application/xhtml+xml" = firefox;
        "text/html" = firefox;
        "x-scheme-handler/http" = firefox;
        "x-scheme-handler/https" = firefox;
      };
  };

  programs.caelestia = {
    enable = true;
    cli.enable = true;
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = cursorTheme;
    size = cursorSize;
    hyprcursor = {
      enable = true;
      size = cursorSize;
    };
  };

  home.file.".config/caelestia".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dotfiles/caelestia/.config/caelestia";

  home.file.".config/fastfetch".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dotfiles/fastfetch/.config/fastfetch";

  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/dotfiles/hypr/.config/hypr";

  home.file.".local/bin".source = ../../dotfiles/local/.local/bin;
  home.file.".local/share/applications".source = ../../dotfiles/local/.local/share/applications;
}
