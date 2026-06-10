{ lib, pkgs, ... }:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
in
{
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

  programs.codex = lib.mkIf isLinux {
    enable = true;
  };

  programs.claude-code = lib.mkIf isLinux {
    enable = true;
  };
}
