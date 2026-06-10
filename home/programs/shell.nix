{
  config,
  lib,
  pkgs,
  ...
}:

{
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

  programs.fzf.enable = true;

  programs.zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
  };

  home.file = {
    ".p10k.zsh".source = ../../dotfiles/zsh/.p10k.zsh;
    ".config/zsh/functions.zsh".source = ../../dotfiles/zsh/.config/zsh/functions.zsh;
  };
}
