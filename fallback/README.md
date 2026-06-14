# Non-Nix Fallback Kit

This directory is for machines where Nix is not available but a few essentials
are still useful.

It intentionally contains only portable shell, tmux, and editor configuration:

- zsh: `.zshrc`, `.p10k.zsh`, and `functions.zsh`
- tmux: `.tmux.conf`
- vim: `.vimrc` and `.exrc`

The normal setup is still Home Manager via the root flake. This fallback kit is
not a replacement for the full managed configuration.

The installer creates symlinks by default. Use `--copy` to copy files instead,
or `--force` to replace an existing file or symlink.

Clone only the essentials and run the installer:

```sh
git clone --filter=blob:none --sparse https://github.com/tea-ok/dotfiles.git ~/dotfiles-essentials && cd ~/dotfiles-essentials && git sparse-checkout set --no-cone '/fallback/install.sh' '/fallback/essentials/*' && ./fallback/install.sh
```
