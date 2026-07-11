# Neovim notes

Leader key is `Space`.

## Navigation

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between splits (also works across tmux panes) |
| `[b` / `]b` | Previous / next buffer |
| `H` / `L` | Start / end of line |
| `Space x` | Close buffer |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward |
| `Ctrl+d` / `Ctrl+u` | Scroll half-page down/up (cursor stays centered) |
| `]d` / `[d` | Next / previous diagnostic |
| `]c` / `[c` | Next / previous git hunk |
| `]m` / `[m` | Next / previous function start |
| `]]` / `[[` | Next / previous class start |

## Tabs

| Key | Action |
|-----|--------|
| `gt` / `gT` | Next / previous tab |
| `Ctrl+w T` | Move current split into its own tab |
| `:tabnew` | Open a new tab |
| `:tabclose` | Close current tab |

## Splits

| Key | Action |
|-----|--------|
| `Ctrl+w v` | Open vertical split (same file) |
| `Ctrl+w s` | Open horizontal split (same file) |
| `Ctrl+w q` | Close current split |
| `Ctrl+w o` | Close all other splits |
| `Ctrl+↑/↓` | Resize split taller/shorter |
| `Ctrl+←/→` | Resize split wider/narrower |

## File tree

| Key | Action |
|-----|--------|
| `Space e` | Toggle file tree |

Inside the tree:

| Key | Action |
|-----|--------|
| `Enter` / `o` | Open file |
| `s` | Open in vertical split |
| `i` | Open in horizontal split |
| `t` | Open in new tab |
| `a` | Create file or directory (trailing `/` = directory) |
| `d` | Delete |
| `r` | Rename |
| `x` | Cut |
| `c` | Copy |
| `p` | Paste |
| `y` | Copy filename |
| `H` | Toggle hidden files |
| `R` | Refresh |
| `q` | Close tree |
| `g?` | Show all keybinds |

## Flash

Type `s` followed by two characters to jump anywhere on screen with labelled targets.

| Key | Mode | Action |
|-----|------|--------|
| `s` | normal / visual / operator | Jump to any position (2-char search + label) |
| `S` | normal / operator | Jump to a treesitter node |
| `r` | operator | Remote flash — apply operator on distant location without moving |
| `R` | operator / visual | Treesitter search across buffer |

**Examples:** `ysf"` — surround a flash target with quotes. `df<label>` — delete up to a jump target.

## Telescope

| Key | Action |
|-----|--------|
| `Space ff` | Find files |
| `Space fh` | Find files (including hidden) |
| `Space fg` | Git files |
| `Space fw` | Live grep |
| `Space fb` | Open buffers |

Inside Telescope: `Ctrl+j/k` or arrows to navigate, `Enter` to open, `Ctrl+v` to open in vertical split, `Ctrl+x` for horizontal split, `Ctrl+c` / `Esc` to close.

## LSP

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
| `Space rn` | Rename symbol |
| `Space ca` | Code actions |

Language servers are managed with `:Mason`.

## Treesitter text objects

Work in visual and operator-pending mode — combine with any operator (`d`, `y`, `c`, `v`, etc.).

| Key | Action |
|-----|--------|
| `af` / `if` | Around / inside function |
| `ac` / `ic` | Around / inside class |
| `aa` / `ia` | Around / inside argument |

`lookahead` is on — if the cursor isn't inside a text object it jumps forward to the next one.

**Examples:** `daf` — delete whole function. `via` — select an argument. `cif` — change function body.

## Git hunks

| Key | Action |
|-----|--------|
| `]c` / `[c` | Next / previous hunk |
| `Space hp` | Preview hunk inline |
| `Space hr` | Reset hunk to HEAD |

## Rust

| Key | Action |
|-----|--------|
| `Space ra` | Rust code actions / Clippy suggestions |

## Haskell

Haskell support uses `haskell-language-server-wrapper` when available. Formatting runs through `fourmolu`, with HLS formatting as the fallback.

## Completion

| Key | Action |
|-----|--------|
| `Ctrl+Space` | Trigger completion |
| `Ctrl+j` / `Tab` | Next item |
| `Ctrl+k` / `Shift+Tab` | Previous item |
| `Ctrl+b` / `Ctrl+f` | Scroll docs up/down |
| `Enter` | Confirm (only if explicitly selected) |
| `Ctrl+e` | Abort |

## Comments

| Key | Action |
|-----|--------|
| `gcc` | Toggle comment on current line |
| `gc{motion}` | Toggle comment over a motion |
| `gc` | Toggle comment on selected lines in visual mode |
| `/` | Toggle comments on selected lines in visual mode |

## Multi-line editing

### LSP rename
`Space rn` renames a symbol everywhere it's used — across the whole project, scope-aware. Prefer this over find-and-replace for variable/function names when an LSP is attached.

### Visual block mode
`Ctrl+v` enters visual-block mode. Select a column across multiple consecutive lines, then:

| Key | Action |
|-----|--------|
| `I` | Insert text before the selection on all lines |
| `A` | Append text after the selection on all lines |
| `d` / `x` | Delete the selected column |
| `r{char}` | Replace selected column with a character |

Type your text, then `Esc` — it applies to all selected lines.

### `gn` + dot-repeat (targeted edits)
1. `/foo` — search for the pattern
2. `cgn` — change the next match (edit, then `Esc`)
3. `.` — repeat on the next match; `n` to skip

### Find and replace in file
`:%s/old/new/gc` — `g` replaces all occurrences, `c` asks for confirmation on each.

## Text manipulation

| Key | Action |
|-----|--------|
| `p` | Paste without overwriting clipboard |
| `J` / `K` | Move selected block down/up (enter visual-block with `Ctrl+v`) |

## Formatting

| Key | Action |
|-----|--------|
| `Space fm` | Format buffer |

Format on save is enabled. Uses LSP formatting as fallback when no formatter is configured.

## Surround

| Key | Action |
|-----|--------|
| `ys{motion}{char}` | Add surround (e.g. `ysiw"` wraps word in quotes) |
| `S{char}` | Surround visual selection |
| `ds{char}` | Delete surround (e.g. `ds"`) |
| `cs{old}{new}` | Change surround (e.g. `cs"'`) |

**Bracket spacing:** opening brackets (`(`, `{`, `[`) add inner spaces — e.g. `S(` → `( foo )`. Use the closing bracket (`)`、`}`、`]`) to surround without spaces — e.g. `S)` → `(foo)`.

## Snacks

| Key | Action |
|-----|--------|
| `Space gg` | Open lazygit |
| `Space z` | Toggle zen mode |

## Sessions

| Key | Action |
|-----|--------|
| `Space ss` | Search saved workspace sessions |
| `Space sl` | Restore workspace session |
| `Space sw` | Save workspace session |
| `Space st` | Toggle workspace autosave |

Inside the session picker:

| Key | Action |
|-----|--------|
| `Enter` | Restore selected session |
| `Ctrl+d` / `dd` | Delete selected session |
| `Ctrl+s` | Switch to alternate session |
| `Ctrl+y` | Copy selected session path |

Sessions are saved per project/workdir. Opening Neovim in a directory without a saved session starts clean; use `Space ss` to switch to another saved session when you want one.

## Plugin management

| Command | Action |
|---------|--------|
| `:Lazy` | Open lazy.nvim UI |
| `:Mason` | Open Mason LSP installer |
