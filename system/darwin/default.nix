{ config
, pkgs
, self
, homebrew-core
, homebrew-cask
, ...
}:

{
  networking = {
    hostName = "mac";
    localHostName = "mac";
    computerName = "mac";
  };

  system.primaryUser = "taavi";

  users.users."taavi".home = "/Users/taavi";

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [
    karabiner-elements
    ghostty-bin
    neovide
    zed-editor
    proton-vpn
    _1password-gui
    obsidian
    spotify
    discord
    claude-code
    codex
    aerospace
    jankyborders
    kitty
    protonmail-desktop
  ];

  launchd.user.agents.jankyborders = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.jankyborders}/bin/borders"
        "active_color=glow(0xffd0bcff)"
        "inactive_color=0xff494d64"
        "width=5.0"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardOutPath = "/tmp/jankyborders.out.log";
      StandardErrorPath = "/tmp/jankyborders.err.log";
    };
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "taavi";
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
    mutableTaps = false;
  };

  homebrew = {
    enable = true;
    taps = builtins.attrNames config.nix-homebrew.taps;
    masApps = {
      "WhatsApp" = 310633997;
      "1password Safari extension" = 1569813296;
    };
    onActivation.cleanup = "zap";
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
  };

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "left";
    };
  };

  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true;

  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 6;
}
