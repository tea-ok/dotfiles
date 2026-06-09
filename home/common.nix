{
  config,
  lib,
  pkgs,
  ...
}:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  home.stateVersion = "26.05";

  xdg.enable = true;
  fonts.fontconfig.enable = true;

  home.packages =
    with pkgs;
    [
      neovim
      vim
      ripgrep
      fd
      gh
      jq
      uv
      fastfetch
      stylua
      prettier
      markdownlint-cli2
      tree-sitter
      ruff
      ty
      htop
      go
      gopls
      unzip
      nerd-fonts.jetbrains-mono
      zsh-completions
    ]
    ++ lib.optionals isLinux [
      _1password-gui
      discord
      spotify
      obsidian
      proton-vpn
    ];

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.local/bin"
    "$HOME/go/bin"
  ] ++ lib.optional isDarwin "/usr/local/go/bin";

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    defaultKeymap = "emacs";

    shellAliases = {
      ls = "eza --icons --group-directories-first";
      tree = "eza --tree --level=2 --icons --git";
      ll = "eza -l --icons";
      la = "eza -la --icons";
      vim = "nvim";
      cat = "bat";
    };

    history = {
      size = 5000;
      save = 5000;
      path = "${config.home.homeDirectory}/.zsh_history";
      append = true;
      share = true;
      ignoreSpace = true;
      ignoreDups = true;
      ignoreAllDups = true;
      saveNoDups = true;
      findNoDups = true;
    };

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "aws"
        "kubectl"
        "kubectx"
        "command-not-found"
      ];
      extraConfig = ''
        source ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/git.zsh
      '';
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      (lib.mkOrder 1000 ''
        HISTDUP=erase

        bindkey '^p' history-search-backward
        bindkey '^n' history-search-forward

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

        [[ -f ~/.config/zsh/functions.zsh ]] && source ~/.config/zsh/functions.zsh
      '')
      (lib.mkOrder 1300 ''
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # machine-local config (not tracked in version control)
        [[ -f ~/.config/zsh/local.zsh ]] && source ~/.config/zsh/local.zsh
      '')
    ];
  };

  programs.tmux = {
    enable = true;
    prefix = "C-s";
    mouse = true;
    baseIndex = 1;
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
    ];
    extraConfig = ''
      unbind r
      bind r source-file ~/.tmux.conf

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      set-option -g renumber-windows on

      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      bind -n S-Left  previous-window
      bind -n S-Right next-window

      bind -n M-H previous-window
      bind -n M-L next-window

      set -g automatic-rename on
      set -g automatic-rename-format "#{host_short}"

      set -g status-interval 5
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=#303446,fg=#c6d0f5"
      set -g message-style "bg=#e5c890,fg=#303446,bold"
      set -g message-command-style "bg=#8caaee,fg=#303446,bold"

      set -g pane-border-style "fg=#51576d"
      set -g pane-active-border-style "fg=#a6d189"

      set -g window-status-separator ""
      set -g window-status-style "fg=#c6d0f5,bg=#414559"
      set -g window-status-format "#[fg=#303446,bg=#414559]#[fg=#c6d0f5,bg=#414559] #I #W #[fg=#414559,bg=#303446]"
      set -g window-status-current-style "fg=#303446,bg=#a6d189,bold"
      set -g window-status-current-format "#[fg=#303446,bg=#a6d189]#[fg=#303446,bg=#a6d189,bold] #I #W #[fg=#a6d189,bg=#303446]"
      set -g window-status-last-style "fg=#c6d0f5,bg=#51576d"
      set -g window-status-activity-style "fg=#e5c890,bg=#414559"
      set -g window-status-bell-style "fg=#303446,bg=#ef9f76,bold"

      set -g status-left-length 80
      set -g status-right-length 0
      set -g status-left "#[fg=#303446,bg=#ca9ee6,bold] ❐ #S #[fg=#ca9ee6,bg=#8caaee,nobold]#[fg=#303446,bg=#8caaee] #{=/40/...;s|^#{HOME}|~|:pane_current_path} #[fg=#8caaee,bg=#303446]"
      set -g status-right ""

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      unbind s
      bind s split-window -h -c "#{pane_current_path}"
      bind i split-window -v -c "#{pane_current_path}"
    '';
  };

  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Frappe";
    themes."Catppuccin Frappe" = {
      src = ../bat/.config/bat/themes;
      file = "Catppuccin Frappe.tmTheme";
    };
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = false;
  };

  programs.fzf.enable = true;
  programs.zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
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
    extraConfig = builtins.readFile ../btop/.config/btop/btop.conf;
    themes.catppuccin_frappe = ../btop/.config/btop/themes/catppuccin_frappe.theme;
  };

  programs.git.enable = true;

  programs.neovide = {
    enable = true;
    settings = {
      font = {
        normal = [ { family = "JetBrainsMono Nerd Font"; } ];
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

  programs.opencode = {
    enable = true;
    settings = {
      plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];
      model = "openai/gpt-5.4-mini";
      small_model = "openai/gpt-5.4-mini";
      enabled_providers = [
        "openai"
        "github-copilot"
      ];
      provider = {
        openai.options = {
          timeout = 600000;
          chunkTimeout = 30000;
        };
        anthropic.options = {
          timeout = 600000;
          chunkTimeout = 30000;
        };
      };
      agent = {
        plan = {
          model = "openai/gpt-5.4";
          reasoningEffort = "high";
        };
        build = {
          model = "openai/gpt-5.4-mini";
          reasoningEffort = "xhigh";
        };
      };
      permission = {
        bash = {
          "*" = "ask";
          "ls" = "allow";
          "ls *" = "allow";
          "cat *" = "allow";
          "pwd" = "allow";
          "echo *" = "allow";
          "which *" = "allow";
          "env" = "allow";
          "find *" = "allow";
          "grep *" = "allow";
          "git status" = "allow";
          "git status *" = "allow";
          "git log" = "allow";
          "git log *" = "allow";
          "git diff" = "allow";
          "git diff *" = "allow";
          "git show *" = "allow";
          "git branch" = "allow";
          "git branch *" = "allow";
          "git commit *" = "ask";
          "git push *" = "deny";
          "git push" = "deny";
          "git send-pack" = "deny";
          "git send-pack *" = "deny";
          "git rebase *" = "ask";
          "git reset *" = "ask";
          "gh *" = "deny";
          "gh help*" = "allow";
          "gh -h*" = "allow";
          "gh --help*" = "allow";
          "gh version*" = "allow";
          "gh -v*" = "allow";
          "gh --version*" = "allow";
          "gh * list*" = "allow";
          "gh * view*" = "allow";
          "gh * status*" = "allow";
          "gh * check*" = "allow";
          "gh * diff*" = "allow";
          "gh * watch*" = "allow";
          "gh search*" = "allow";
          "gh browse*" = "allow";
          "gh * download*" = "allow";
          "gh * clone*" = "allow";
          "rm *" = "deny";
          "rm -rf *" = "deny";
        };
        edit = "ask";
        read = {
          "*" = "allow";
          "*.env" = "deny";
          "*.env.*" = "deny";
          "*.env.example" = "allow";
        };
        doom_loop = "ask";
      };
      share = "disabled";
      compaction = {
        auto = true;
        prune = true;
        reserved = 10000;
      };
      snapshot = true;
      autoupdate = false;
      experimental.openTelemetry = false;
      watcher.ignore = [
        "node_modules/**"
        "dist/**"
        ".git/**"
        ".next/**"
        ".turbo/**"
      ];
    };
  };

  home.file = {
    ".config/nvim".source = ../nvim/.config/nvim;
    ".ideavimrc".source = ../ideavim/.ideavimrc;
    ".vimrc".source = ../vim/.vimrc;
    ".exrc".source = ../vim/.exrc;
    ".p10k.zsh".source = ../zsh/.p10k.zsh;
    ".config/zsh/functions.zsh".source = ../zsh/.config/zsh/functions.zsh;
    ".config/eza/theme.yml".source = ../eza/.config/eza/theme.yml;
    ".config/htop".source = ../htop/.config/htop;
  };

  programs.codex = lib.mkIf isLinux {
    enable = true;
  };

  programs.claude-code = lib.mkIf isLinux {
    enable = true;
  };
}
