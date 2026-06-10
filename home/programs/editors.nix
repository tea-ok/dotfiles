{ config, ... }:

{
  programs.neovide = {
    enable = true;
    settings = {
      font = {
        normal = [{ family = "JetBrainsMono Nerd Font"; }];
        size = 20.0;
      };
    };
  };

  programs.zed-editor = {
    enable = true;
    mutableUserSettings = false;
    mutableUserKeymaps = false;
    userSettings = {
      disable_ai = true;
      cli_default_open_behavior = "new_window";
      terminal.font_family = "JetBrainsMono Nerd Font";
      git.inline_blame.enabled = false;
      vim.toggle_relative_line_numbers = true;
      base_keymap = "Emacs";
      icon_theme = {
        mode = "system";
        light = "Catppuccin Latte";
        dark = "Catppuccin Frappe";
      };
      telemetry = {
        diagnostics = true;
        metrics = false;
      };
      vim_mode = true;
      ui_font_size = 22;
      buffer_font_size = 20;
      theme = {
        mode = "dark";
        light = "Catppuccin Latte (Blur)";
        dark = "Catppuccin Frappe (Blur)";
      };
    };
    userKeymaps = [
      {
        context = "VimControl && !menu";
        bindings = {
          shift-h = "vim::FirstNonWhitespace";
          shift-l = "vim::EndOfLine";
        };
      }
      {
        context = "vim_mode == normal && !menu";
        bindings = {
          "space t t" = "terminal_panel::Toggle";
          "space t h" = "terminal_panel::Toggle";
          "space g g" = "git_panel::ToggleFocus";
          "space z" = "workspace::ToggleCenteredLayout";
          "space x" = "pane::CloseActiveItem";
          "] b" = "pane::ActivateNextItem";
          "[ b" = "pane::ActivatePreviousItem";
          "] d" = "editor::GoToDiagnostic";
          "[ d" = "editor::GoToPreviousDiagnostic";
          "space r n" = "editor::Rename";
          "space c a" = "editor::ToggleCodeActions";
          "g o" = "editor::GoToTypeDefinition";
          "space k" = "editor::Hover";
          "space f f" = "file_finder::Toggle";
          "space f w" = "workspace::NewSearch";
          "space f b" = "tab_switcher::Toggle";
          ctrl-h = "workspace::ActivatePaneLeft";
          ctrl-j = "workspace::ActivatePaneDown";
          ctrl-k = "workspace::ActivatePaneUp";
          ctrl-l = "workspace::ActivatePaneRight";
          "space e" = "project_panel::ToggleFocus";
          shift-q = null;
        };
      }
      {
        context = "vim_mode == visual && !menu";
        bindings = {
          shift-j = "editor::MoveLineDown";
          shift-k = "editor::MoveLineUp";
          "/" = "editor::ToggleComments";
          shift-s = "vim::PushAddSurrounds";
        };
      }
      {
        context = "Editor && showing_completions";
        bindings = {
          tab = "editor::ContextMenuNext";
          shift-tab = "editor::ContextMenuPrevious";
          enter = "editor::ConfirmCompletion";
        };
      }
      {
        context = "Terminal";
        bindings."ctrl-\\" = "terminal_panel::Toggle";
      }
    ];
  };

  home.file = {
    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/dotfiles/nvim/.config/nvim";
    ".ideavimrc".source = ../../dotfiles/ideavim/.ideavimrc;
    ".vimrc".source = ../../dotfiles/vim/.vimrc;
    ".exrc".source = ../../dotfiles/vim/.exrc;
  };
}
