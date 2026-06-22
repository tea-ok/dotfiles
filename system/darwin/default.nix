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
    kitty
    protonmail-desktop
  ];

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
    dock.autohide = false;
  };

  nix.settings.experimental-features = "nix-command flakes";

  programs.zsh.enable = true;

  system.configurationRevision = self.rev or self.dirtyRev or null;

  system.stateVersion = 6;
}
