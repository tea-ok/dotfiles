{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Core system stuff.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nix";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Helsinki";
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.hardware.openrgb.enable = true;
  services.keyd = {
    enable = true;
  };

  # Useful programs.
  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
  };

  users.users.taavi = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

  # This has to be here instead of in home-manager.
  programs.ssh = {
    extraConfig = "
    Host *
      IdentityAgent ~/.1password/agent.sock
    ";
  };

  # Niri + dms + greetd.
  programs.niri.enable = true;
  systemd.user.services.niri.enableDefaultPath = false;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.seahorse.enable = true;
  programs.dms-shell = {
    enable = true;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
  };
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --asterisks --user-menu --cmd ${config.programs.niri.package}/bin/niri-session";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    ghostty
    openrgb-with-all-plugins
    kdePackages.dolphin
    kdePackages.qtsvg
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason
  system.stateVersion = "26.05";
}
