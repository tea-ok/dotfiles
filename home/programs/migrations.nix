{ lib, ... }:

{
  home.activation.cleanupLegacyDotfileLinks = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    legacyManagedLinks=(
      ".zshrc"
      ".p10k.zsh"
      ".tmux.conf"
      ".vimrc"
      ".exrc"
      ".ideavimrc"
      ".config/btop"
      ".config/eza/theme.yml"
      ".config/ghostty/shaders"
      ".config/ghostty/themes/dankcolors"
      ".config/htop"
      ".config/niri"
      ".config/nvim"
      ".config/quickshell"
      ".config/DankMaterialShell"
      ".config/gtk-3.0"
      ".config/gtk-4.0"
      ".config/kdeglobals"
      ".config/rofi/themes/catppuccin-frappe.rasi"
      ".config/zsh/functions.zsh"
      ".local/bin"
      ".local/share/applications"
    )

    for rel in "''${legacyManagedLinks[@]}"; do
      path="$HOME/$rel"
      if [[ -L "$path" ]]; then
        target="$(readlink "$path")"
        case "$target" in
          dotfiles/*|../dotfiles/*|../../dotfiles/*|"$HOME/dotfiles/"*)
            run rm -f "$path"
            ;;
        esac
      fi
    done
  '';
}
