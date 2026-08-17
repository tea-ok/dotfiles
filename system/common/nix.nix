# Shared between darwin and nixos. Keeps the store from growing without bound:
# every rebuild pins a full closure, and tracking nixpkgs-unstable means
# consecutive generations share almost nothing.
{
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Hardlinks identical files across store paths.
  nix.optimise.automatic = true;
}
