# nvim-neovide keybinds

Leader key is `Space`.

## Navigation

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between splits |
| `Shift+h` / `Shift+l` | Previous / next buffer |
| `Ctrl+d` / `Ctrl+u` | Scroll half-page down/up (cursor stays centered) |

## Splits

| Key | Action |
|-----|--------|
| `Ctrl+↑/↓` | Resize split horizontally |
| `Ctrl+←/→` | Resize split vertically |

## File tree (nvim-tree)

| Key | Action |
|-----|--------|
| `Space e` | Toggle file tree |

Inside the tree, default nvim-tree binds apply: `Enter` to open, `a` to create, `d` to delete, `r` to rename, `R` to refresh.

## Telescope (fuzzy finder)

| Key | Action |
|-----|--------|
| `Space ff` | Find files |
| `Space fh` | Find files (including hidden) |
| `Space fg` | Git files |
| `Space fw` | Live grep |
| `Space fb` | Open buffers |

Inside Telescope: `Ctrl+j/k` or arrows to navigate, `Enter` to open, `Ctrl+c` / `Esc` to close.

## LSP (active when a language server is attached)

| Key | Action |
|-----|--------|
| `K` | Hover docs |
| `Space k` | Show diagnostic float |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `go` | Go to type definition |
| `gr` | References |
| `gs` | Signature help |
| `F2` | Rename symbol |
| `F4` | Code actions |

Language servers are managed with `:Mason`.

## Completion (nvim-cmp)

| Key | Action |
|-----|--------|
| `Ctrl+Space` | Trigger completion |
| `Ctrl+j` / `Tab` | Next item |
| `Ctrl+k` / `Shift+Tab` | Previous item |
| `Ctrl+b` / `Ctrl+f` | Scroll docs up/down |
| `Enter` | Confirm (only if explicitly selected) |
| `Ctrl+e` | Abort |

## Text manipulation (visual / visual-block mode)

| Key | Action |
|-----|--------|
| `Alt+j` / `Alt+k` | Move selected lines down/up |
| `p` | Paste without overwriting clipboard |
| `J` / `K` | Move selected block down/up (visual-block) |

## Formatting (conform.nvim)

| Key | Action |
|-----|--------|
| `Space fm` | Format buffer |

Format on save is enabled. Uses LSP formatting as fallback when no formatter is configured.

## Surround (nvim-surround)

| Key | Action |
|-----|--------|
| `ys{motion}{char}` | Add surround (e.g. `ysiw"` wraps word in quotes) |
| `ds{char}` | Delete surround (e.g. `ds"`) |
| `cs{old}{new}` | Change surround (e.g. `cs"'`) |

## Snacks

| Key | Action |
|-----|--------|
| `Space tt` | Open terminal |
| `Space gg` | Open lazygit |

## Terminal mode

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Exit terminal and move to that split |

## Plugin management

| Command | Action |
|---------|--------|
| `:Lazy` | Open lazy.nvim UI |
| `:Mason` | Open Mason LSP installer |
