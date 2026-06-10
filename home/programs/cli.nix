{ pkgs
, ...
}:

{
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Frappe";
    themes."Catppuccin Frappe" = {
      src = ../../dotfiles/bat/.config/bat/themes;
      file = "Catppuccin Frappe.tmTheme";
    };
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      theme = {
        activeBorderColor = [
          "#8caaee"
          "bold"
        ];
        inactiveBorderColor = [ "#a5adce" ];
        searchingActiveBorderColor = [ "#e5c890" ];
        optionsTextColor = [ "#8caaee" ];
        selectedLineBgColor = [ "#414559" ];
        inactiveViewSelectedLineBgColor = [ "#737994" ];
        cherryPickedCommitFgColor = [ "#8caaee" ];
        cherryPickedCommitBgColor = [ "#51576d" ];
        markedBaseCommitFgColor = [ "#8caaee" ];
        markedBaseCommitBgColor = [ "#e5c890" ];
        unstagedChangesColor = [ "#e78284" ];
        defaultFgColor = [ "#c6d0f5" ];
      };
      authorColors."*" = "#babbf1";
    };
  };

  programs.btop = {
    enable = true;
    extraConfig = builtins.readFile ../../dotfiles/btop/.config/btop/btop.conf;
    themes.catppuccin_frappe = ../../dotfiles/btop/.config/btop/themes/catppuccin_frappe.theme;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "tea-ok";
        email = "70608286+tea-ok@users.noreply.github.com";
      };
      init.defaultBranch = "main";
    };
  };

  home.file = {
    ".config/eza/theme.yml".source = ../../dotfiles/eza/.config/eza/theme.yml;
    ".config/htop".source = ../../dotfiles/htop/.config/htop;
  };
}
