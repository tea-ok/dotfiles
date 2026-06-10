{ inputs }:

let
  inherit (inputs)
    self
    nix-darwin
    home-manager
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
        _module.args = {
          inherit
            self
            homebrew-core
            homebrew-cask
            ;
        };

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${repo.users.darwin.username} = {
          imports = [
            ../home/profiles/common.nix
            ../home/profiles/darwin.nix
          ];
        };
      }
    ];
  };

  homeConfigurations.${repo.hosts.arch.homeConfiguration} = repo.mkHome {
    system = repo.hosts.arch.system;
    modules = [
      ../home/profiles/common.nix
      ../home/profiles/arch.nix
    ];
  };
}
