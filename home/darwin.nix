{ pkgs, ... }:

{
  home.username = "taavi-ok";
  home.homeDirectory = "/Users/taavi-ok";

  # Darwin GUI apps are materialized by nix-darwin into /Applications/Nix Apps,
  # matching the pre-refactor behavior that Finder/Spotlight picked up.
  targets.darwin.copyApps.enable = false;

  programs.neovide.package = null;
  programs.zed-editor.package = null;

  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      background-opacity = 0.95;
      window-padding-x = 0;
      window-padding-y = 0;
      background-blur-radius = 5;
      font-size = 20;
      custom-shader = "shaders/cursor_warp.glsl";
      custom-shader-animation = "always";
      theme = "Catppuccin Frappe";
    };
  };

  home.file.".config/ghostty/shaders".source =
    ../ghostty + "/Library/Application Support/com.mitchellh.ghostty/shaders";
}
