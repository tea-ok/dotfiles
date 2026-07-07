{
  description = "Project development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config.allowUnfree = false;
            }
          )
        );
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # Add project tools here.
          ];

          shellHook = ''
            echo "dev shell: $(basename "$PWD")"

            # Hand interactive shells to zsh so ~/.zshrc is loaded as usual.
            # Non-interactive `nix develop -c <cmd>` stays in bash.
            if [[ $- == *i* ]]; then
              exec ${pkgs.zsh}/bin/zsh
            fi
          '';
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
