{ inputs }:

rec {
  users = {
    darwin = {
      username = "taavi-ok";
      homeDirectory = "/Users/taavi-ok";
    };

    arch = {
      username = "taavi";
      homeDirectory = "/home/taavi";
    };
  };

  hosts = {
    darwin = {
      name = "Taavis-MacBook-Air";
      system = "aarch64-darwin";
    };

    arch = {
      name = "arch";
      system = "x86_64-linux";
      homeConfiguration = "${users.arch.username}@arch";
    };
  };

  mkPkgs =
    system:
    import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  mkHome =
    {
      system,
      modules,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      inherit modules;
    };
}
