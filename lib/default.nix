{ inputs }:

rec {
  users = {
    darwin = {
      username = "taavi-ok";
      homeDirectory = "/Users/taavi-ok";
    };

    nixos = {
      username = "taavi";
      homeDirectory = "/home/taavi";
    };
  };

  hosts = {
    darwin = {
      name = "Taavis-MacBook-Air";
      system = "aarch64-darwin";
    };

    nixos = {
      name = "nix";
      system = "x86_64-linux";
      homeConfiguration = "${users.nixos.username}@nix";
    };
  };

  mkPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  mkHome =
    { system
    , modules
    ,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      inherit modules;
    };
}
