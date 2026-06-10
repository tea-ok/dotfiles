{
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
    ../../dotfiles/ghostty + "/Library/Application Support/com.mitchellh.ghostty/shaders";
}
