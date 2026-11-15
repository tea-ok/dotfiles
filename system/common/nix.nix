# Tracking unstable means generations share little, so collect garbage regularly.
{
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  nix.optimise.automatic = true;
}
