# nvim keybinds

Leader key is `Space`.

## Navigation

| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between splits |
| `Shift+h` / `Shift+l` | Previous / next buffer |
| `Space x` | Close buffer |
| `Ctrl+d` / `Ctrl+u` | Scroll half-page down/up (cursor stays centered) |

## Splits

| Key | Action |
|-----|--------|
| `Ctrl+w v` | Open vertical split (same file) |
| `Ctrl+w s` | Open horizontal split (same file) |
| `Ctrl+w o` | Close all other splits |
| `Ctrl+↑/↓` | Resize split taller/shorter |
| `Ctrl+←/→` | Resize split wider/narrower |

## File tree (nvim-tree)

| Key | Action |
|-----|--------|
| `Space e` | Toggle file tree |

Inside the tree:

| Key | Action |
|-----|--------|
| `Enter` / `o` | Open file |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+x` | Open in horizontal split |
| `Ctrl+t` | Open in new tab |
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

## Telescope (fuzzy finder)

| Key | Action |
|-----|--------|
| `Space ff` | Find files |
| `Space fh` | Find files (including hidden) |
| `Space fg` | Git files |
| `Space fw` | Live grep |
| `Space fb` | Open buffers |

Inside Telescope: `Ctrl+j/k` or arrows to navigate, `Enter` to open, `Ctrl+v` to open in vertical split, `Ctrl+x` for horizontal split, `Ctrl+c` / `Esc` to close.

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
| `Space rn` | Rename symbol |
| `Space ca` | Code actions |

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
| `p` | Paste without overwriting clipboard |
| `J` / `K` | Move selected block down/up (enter visual-block with `Ctrl+v`) |

## Formatting (conform.nvim)

| Key | Action |
|-----|--------|
| `Space fm` | Format buffer |

Format on save is enabled. Uses LSP formatting as fallback when no formatter is configured.

## Surround (nvim-surround)

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

---

## Workflows

### Opening files side by side

**From the file tree:** `Space e` to open the tree, navigate to the first file and press `Enter`, then navigate to the second file and press `Ctrl+v` to open it in a vertical split beside the first. `Space e` again to close the tree.

**From Telescope:** `Space ff` to search, press `Enter` on the first file to open it, then `Space ff` again and this time press `Ctrl+v` on the second file to open it in a split.

**Splitting a file you already have open:** `Ctrl+w v` to duplicate it into a vertical split, then `Space ff` or `gd` to navigate to something else in one pane while keeping context in the other.

### Jumping to a definition without losing your place

Press `gd` on a symbol to jump to its definition. Use `Ctrl+o` to jump back. If you want to keep both visible at once, split first: `Ctrl+w v` then `gd` in the new pane — your original file stays open on the left.

### Exploring references

`gr` opens a Telescope picker with every reference to the symbol under the cursor. Navigate with `Ctrl+j/k`, press `Enter` to jump or `Ctrl+v` to open the reference in a split alongside what you're currently editing.

### Terminal alongside code

`Space tt` toggles a terminal at the bottom. `Ctrl+j` moves into the terminal, `Ctrl+k` moves back up to the editor. The terminal stays running in the background when toggled off — toggle it back on with `Space tt` and your session is still there.

### Typical Rust session

1. Open the project root in nvim.
2. `Space e` to browse the file tree, open the file you want.
3. Edit — completions and inlay hints come from rust-analyzer automatically.
4. `Space k` on an error to read the diagnostic. `Space ca` for quick fixes.
5. `gd` to jump to a definition; `Ctrl+o` to come back.
6. `Space fm` to format (or just save — format-on-save is on).
7. `Space gg` to open lazygit for committing.
