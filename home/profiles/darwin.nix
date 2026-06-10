{
  imports = [ ../desktop/ghostty-darwin.nix ];

  home.username = "taavi-ok";
  home.homeDirectory = "/Users/taavi-ok";

  # Darwin GUI apps are materialized by nix-darwin into /Applications/Nix Apps,
  # matching the pre-refactor behavior that Finder/Spotlight picked up.
  targets.darwin.copyApps.enable = false;

  programs.neovide.package = null;
  programs.zed-editor.package = null;
}
