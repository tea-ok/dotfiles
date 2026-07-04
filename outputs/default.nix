{ inputs }:

let
  inherit (inputs)
    self
    nixpkgs
    nix-darwin
    home-manager
    caelestia-shell
    zig-overlay
    zls
    nix-homebrew
    homebrew-core
    homebrew-cask
    ;

  repo = import ../lib { inherit inputs; };
in
{
  darwinConfigurations.${repo.hosts.darwin.name} = nix-darwin.lib.darwinSystem {
    specialArgs = {
      inherit
        self
        homebrew-core
        homebrew-cask
        ;
    };

    modules = [
      ../system/darwin
      nix-homebrew.darwinModules.nix-homebrew
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "backup";
        home-manager.extraSpecialArgs = {
          inherit
            self
            zig-overlay
            zls
            homebrew-core
            homebrew-cask
            ;
        };
        home-manager.users.${repo.users.darwin.username} = {
          imports = [
            ../home/profiles/common.nix
            ../home/profiles/darwin.nix
          ];
        };
      }
    ];
  };

  nixosConfigurations.${repo.hosts.nixos.name} = nixpkgs.lib.nixosSystem {
    system = repo.hosts.nixos.system;
    modules = [
      ../system/nixos
      home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit
              self
              caelestia-shell
              zig-overlay
              zls
              ;
          };
          users.${repo.users.nixos.username} = {
            imports = [
              ../home/profiles/common.nix
              ../home/profiles/nixos.nix
            ];
          };
          backupFileExtension = "backup";
        };
      }
    ];
  };
}
