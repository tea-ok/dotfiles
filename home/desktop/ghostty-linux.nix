{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      background-opacity = 0.95;
      window-padding-x = 8;
      window-padding-y = 8;
      background-blur-radius = 5;
      font-size = 13;
      theme = "Catppuccin Frappe";
      command = "/usr/bin/zsh";
      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
      ];
    };
  };

  home.file = {
    ".config/ghostty/shaders".source = ../../dotfiles/ghostty/.config/ghostty/shaders;
    ".config/ghostty/themes/dankcolors".source = ../../dotfiles/ghostty/.config/ghostty/themes/dankcolors;
  };
}
