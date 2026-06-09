{
  description = "Taavi's dotfiles and system configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

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

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
    }:
    let
      linuxPkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations."Taavis-MacBook-Air" = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/darwin.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            _module.args = {
              inherit
                self
                homebrew-core
                homebrew-cask
                ;
            };

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."taavi-ok" = {
              imports = [
                ./home/common.nix
                ./home/darwin.nix
              ];
            };
          }
        ];
      };

      homeConfigurations."taavi@arch" = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        modules = [
          ./home/common.nix
          ./home/linux.nix
        ];
      };
    };
}
