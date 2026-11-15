{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nix";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Helsinki";
  services.xserver.xkb = {
    layout = "us,fi";
    options = "grp:alt_shift_toggle";
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Multipoint headsets (Bose QC) re-pair via Just Works when roaming back
    # from another host. BlueZ's default ("never") rejects it, breaking the bond.
    settings.General.JustWorksRepairing = "always";
  };
  # Provides the BlueZ pairing agent; without one, pairing silently fails.
  services.blueman.enable = true;
  # Ignore the unreliable onboard Intel AX210 Bluetooth so only the USB dongle is used.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="8087", ATTR{idProduct}=="0032", ATTR{authorized}="0"
  '';
  services.hardware.openrgb.enable = true;
  services.keyd = {
    enable = true;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      # Only connect headsets with this PC as the sender; otherwise the Bose QC
      # can come up as an input with no output node. Roles are from this PC's
      # side (a2dp_source gives the a2dp-sink profile).
      extraConfig."51-bluez-output-only" = {
        "monitor.bluez.properties" = {
          "bluez5.roles" = [
            "a2dp_source"
            "bap_source"
            "hsp_ag"
            "hfp_ag"
          ];
        };
      };
    };
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  # Suspend only. Hibernating with the NVIDIA driver has hung the machine.
  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    AllowHybridSleep = "no";
  };

  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
  };

  users.users.taavi = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    packages = with pkgs; [
      tree
    ];
  };

  # Has to be system-level, not home-manager.
  programs.ssh = {
    extraConfig = "
    Host *
      IdentityAgent ~/.1password/agent.sock
    ";
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  programs.seahorse.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --asterisks --user-menu --cmd '${config.programs.uwsm.package}/bin/uwsm start -e -D Hyprland hyprland.desktop'";
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

  hardware.graphics = {
    enable = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      kernelSuspendNotifier = true;
      finegrained = false;
    };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # First installed NixOS release; never change it after install.
  system.stateVersion = "26.05";
}
