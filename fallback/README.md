# Non-Nix Fallback Kit

This directory is for machines where Nix is not available but a few essentials
are still useful.

It intentionally contains only portable shell, tmux, and editor configuration:

- zsh: `.zshrc`, `.p10k.zsh`, and `functions.zsh`
- tmux: `.tmux.conf`
- vim: `.vimrc` and `.exrc`
- optional Neovim: `.config/nvim` via `./fallback/install.sh --nvim`

The normal setup is still Home Manager via the root flake. This fallback kit is
not a replacement for the full managed configuration.

For feature parity with the Nix/darwin setup, install these commands with your
system package manager: `zsh`, `tmux`, `vim`, `git`, `eza`, `bat`, `fzf`,
`zoxide`, `ripgrep`, `fd`, `neovim`, and a JetBrains Mono Nerd Font. zsh and vim
plugins bootstrap themselves through Zinit and Vundle. The installer also
bootstraps TPM for tmux plugins; after first install, start tmux and press
`prefix + I` (`C-s` then `I`) to fetch the plugins.

The installer creates symlinks by default. Use `--copy` to copy files instead,
or `--force` to replace an existing file or symlink.

Clone only the essentials and run the installer:

```sh
git clone --filter=blob:none --sparse https://github.com/tea-ok/dotfiles.git ~/dotfiles-essentials && cd ~/dotfiles-essentials && git sparse-checkout set --no-cone '/fallback/install.sh' '/fallback/essentials/*' && ./fallback/install.sh
```

To include Neovim in a sparse clone, add the Neovim config path before running
with `--nvim`:

```sh
git sparse-checkout add --no-cone '/dotfiles/nvim/*' && ./fallback/install.sh --nvim
```
