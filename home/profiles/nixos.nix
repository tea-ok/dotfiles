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

  # DaVinci Resolve bundles its own Qt5, which ships only the `xcb` platform
  # plugin. Under a Wayland session (Hyprland exports QT_QPA_PLATFORM=wayland)
  # its Qt aborts in createPlatformIntegration() at startup (SIGABRT, 0s uptime).
  # Force the bundled apps onto XCB (via XWayland). symlinkJoin keeps the
  # package's own .desktop launchers and icons; wrapping every bin covers
  # Resolve plus the bundled BlackmagicRAW / control-panel utilities, which
  # share the same Qt and would crash the same way.
  davinci-resolve-xcb = pkgs.symlinkJoin {
    name = "davinci-resolve-xcb";
    paths = [ pkgs.davinci-resolve ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in "$out"/bin/*; do
        wrapProgram "$bin" --set QT_QPA_PLATFORM xcb
      done
    '';
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
    davinci-resolve-xcb
    kitty
    protonmail-desktop
    prismlauncher
    brave
    vlc
    obs-studio
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

  # Runs blueman-applet as a user service. Hyprland doesn't process XDG autostart
  # entries, so the system-level services.blueman.enable alone would never start
  # the applet, and without it nothing registers a BlueZ pairing agent.
  services.blueman-applet.enable = true;

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
  home.file.".local/share/applications" = {
    source = ../../dotfiles/local/.local/share/applications;
    recursive = true;
  };
}
