{
  description = "Taavi's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {

      nixpkgs.config.allowUnfree = true;

      # Check https://search.nixos.org for packages.
      environment.systemPackages =
        [ 
          # Open-source terminal software <3
          pkgs.vim
          pkgs.bat
          pkgs.btop
          pkgs.eza
          pkgs.fastfetch
          pkgs.fd
          pkgs.fzf
          pkgs.gh
          pkgs.lazygit
          pkgs.markdownlint-cli2
          pkgs.neovim
          pkgs.prettier
          pkgs.ripgrep
          pkgs.stylua
          pkgs.tmux
          pkgs.uv
          pkgs.yazi
          pkgs.zoxide
          pkgs.opencode
          pkgs.codex

          # Open-source GUI software.
          pkgs.neovide
          pkgs.zed-editor
          pkgs.ghostty-bin
          pkgs.karabiner-elements
          pkgs.proton-vpn

          # Closed-source software.
          pkgs._1password-gui
          pkgs.obsidian
          pkgs.claude-code
          pkgs.spotify
          pkgs.discord

          # Fonts.
          pkgs.nerd-fonts.jetbrains-mono
        ];

      # Homebrew. Removes all brew packages not installed through Nix.
      homebrew = {
          enable = true;
          masApps = {
              "WhatsApp": 310633997;
          };
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
       };

      # macOS system settings.
      system.defaults = {
        dock.autohide = true;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#taavi-mac
    darwinConfigurations."taavi-mac" = nix-darwin.lib.darwinSystem {
      modules = [ configuration,
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "taavi-ok";

            # Optional: Declarative tap management
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };

            # Enable fully-declarative tap management
            # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
            mutableTaps = false;
          };
        }
        # Align homebrew taps config with nix-homebrew
        ({config, ...}: {
          homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })  
      ];
    };
  };
}
