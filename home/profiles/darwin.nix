{ pkgs, ... }:

{
  imports = [
    ../desktop/ghostty-darwin.nix
    ../desktop/kitty.nix
  ];

  home.username = "taavi";
  home.homeDirectory = "/Users/taavi";

  # Darwin GUI apps are materialized by nix-darwin into /Applications/Nix Apps,
  # matching the pre-refactor behavior that Finder/Spotlight picked up.
  targets.darwin.copyApps.enable = false;

  programs.neovide.package = null;
  programs.zed-editor.package = null;

  home.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.symbols-only
  ];
}
