{ pkgs, ... }:

{
  programs.quickshell = {
    enable = true;
    package = pkgs.quickshell;
  };

  home.file = {
    ".config/quickshell".source = ../../dotfiles/quickshell/.config/quickshell;
    ".config/DankMaterialShell".source = ../../dotfiles/dank/.config/DankMaterialShell;
  };
}
