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
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
        if [[ -z "$TMUX" && -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        ZVM_SYSTEM_CLIPBOARD_ENABLED=true
      '')
      (lib.mkOrder 1000 ''
        HISTDUP=erase

        bindkey '^p' history-search-backward
        bindkey '^n' history-search-forward

        function zvm_after_lazy_keybindings() {
          zvm_bindkey vicmd 'H' vi-first-non-blank
          zvm_bindkey vicmd 'L' vi-end-of-line
          zvm_bindkey visual 'H' vi-first-non-blank
          zvm_bindkey visual 'L' vi-end-of-line
        }

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
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor "frappe"
          set -g @catppuccin_window_status_style "basic"
          set -g @catppuccin_status_background "default"

          set -g status-left-length 100
          set -g status-right-length 100
          set -g status-left "#{E:@catppuccin_status_session}"
          set -ag status-left "#{E:@catppuccin_status_directory}"
          set -g status-right "#{E:@catppuccin_status_host}"
        '';
      }
    ];
    extraConfig = builtins.readFile ../../dotfiles/tmux/.tmux.conf;
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
