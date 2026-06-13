{ inputs }:

let
  inherit (inputs)
    self
    nixpkgs
    nix-darwin
    home-manager
    zig-overlay
    nix-homebrew
    homebrew-core
    homebrew-cask
    ;

  repo = import ../lib { inherit inputs; };
in
{
  darwinConfigurations.${repo.hosts.darwin.name} = nix-darwin.lib.darwinSystem {
    modules = [
      ../system/darwin
      nix-homebrew.darwinModules.nix-homebrew
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit
            self
            zig-overlay
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
            inherit self zig-overlay;
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
