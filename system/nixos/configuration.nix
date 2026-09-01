{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Core system stuff.
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
  };
  # blueman-applet registers the BlueZ pairing agent. Without an agent bluetoothd
  # rejects passkey confirmation ("No agent available for request type 2") and
  # pairing silently fails.
  services.blueman.enable = true;
  # The onboard Bluetooth radio is the Intel AX210 combo card (USB 8087:0032),
  # which shares its antennas with WiFi and has been unreliable here for years,
  # across devices and operating systems. Deauthorize it at the USB level so the
  # kernel never binds btusb to it and only the external dongle registers an
  # adapter. Remove this block to go back to the onboard radio.
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
      # Headsets that advertise both A2DP roles (the Bose QC does) can be connected
      # in either direction, and BlueZ kept picking the one where the headset is the
      # sender. That makes this machine a speaker for the headphones, so they showed
      # up only under Input with no output node at all. Keep just the roles where
      # this machine is the sender.
      #
      # Note these role names are from *this machine's* point of view, while the
      # resulting profile names are from the remote device's: role a2dp_source is
      # what produces the a2dp-sink profile. Dropping a2dp_sink is what removes the
      # unwanted direction.
      #
      # Trade-off: this PC can no longer be used as a Bluetooth speaker for a phone.
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

  # Hibernation. The installer's 4G swap partition can't hold a 32G memory
  # image, so hibernate to a swapfile on / instead. resume_offset is the first
  # physical block of /swapfile and has to be updated if the file is recreated:
  #   sudo filefrag -v /swapfile | awk '$1 == "0:" { print $4 }'
  swapDevices = [
    {
      device = "/swapfile";
      size = 32 * 1024;
    }
  ];
  boot.resumeDevice = "/dev/disk/by-uuid/cc78e529-41a4-4a57-b304-302163f6c556";
  boot.kernelParams = [ "resume_offset=400351232" ];

  # Useful programs.
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

  # This has to be here instead of in home-manager.
  programs.ssh = {
    extraConfig = "
    Host *
      IdentityAgent ~/.1password/agent.sock
    ";
  };

  # Hyprland + greetd.
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

  # GPU stuff.
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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason
  system.stateVersion = "26.05";
}
