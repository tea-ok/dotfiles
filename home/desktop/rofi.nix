{
  programs.rofi = {
    enable = true;
    modes = [
      "drun"
      "run"
    ];
    extraConfig = {
      show-icons = true;
      icon-theme = "Papirus-Dark";
      drun-display-format = "{icon} {name}";
    };
    theme = ../../dotfiles/rofi/.config/rofi/themes/spotlight-dark-frappe.rasi;
  };

  home.file.".config/rofi/themes/catppuccin-frappe.rasi".source =
    ../../dotfiles/rofi/.config/rofi/themes/catppuccin-frappe.rasi;
}
