#!/usr/bin/env bash
set -euo pipefail

log() { printf '[apply] %s\n' "$*"; }
die() { printf '[apply] ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
os_is_mac() { [[ "$(uname -s)" == Darwin ]]; }
canonical_path() {
  local path="$1"
  if have realpath; then
    realpath "$path"
  else
    readlink -f "$path"
  fi
}
resolve_stow() {
  local candidate
  for candidate in \
    "${STOW_BIN:-}" \
    "$(command -v stow 2>/dev/null || true)" \
    /home/linuxbrew/.linuxbrew/bin/stow \
    /usr/local/bin/stow \
    /opt/homebrew/bin/stow \
    /usr/bin/stow
  do
    [[ -n "$candidate" && -x "$candidate" ]] && printf '%s\n' "$candidate" && return 0
  done
  return 1
}

package_find_roots() {
  local pkg="$1"

  case "$pkg" in
    ghostty)
      if os_is_mac; then
        printf '%s\n' "Library"
      else
        printf '%s\n' ".config"
      fi
      ;;
    *)
      printf '%s\n' "."
      ;;
  esac
}

package_stow_args() {
  local pkg="$1"

  case "$pkg" in
    ghostty)
      if os_is_mac; then
        printf '%s\n' "--ignore=^\\.config($|/)"
      else
        printf '%s\n' "--ignore=^Library($|/)"
      fi
      ;;
  esac
}

normalize_matching_symlinks() {
  local pkg="$1" target="$2"
  local rel rel_path link_path source_path resolved_link resolved_source root root_path
  declare -A seen=()

  while IFS= read -r root; do
    root_path="$REPO_ROOT/$pkg"
    [[ "$root" == "." ]] || root_path="$root_path/$root"
    [[ -d "$root_path" ]] || continue

    while IFS= read -r rel; do
      rel_path="$rel"
      while [[ -n "$rel_path" && "$rel_path" != "." ]]; do
        if [[ -z "${seen[$rel_path]:-}" ]]; then
          seen["$rel_path"]=1
          link_path="$target/$rel_path"
          source_path="$REPO_ROOT/$pkg/$rel_path"

          if [[ -L "$link_path" && -e "$source_path" ]]; then
            resolved_link="$(canonical_path "$link_path" 2>/dev/null || true)"
            resolved_source="$(canonical_path "$source_path" 2>/dev/null || true)"
            if [[ -n "$resolved_link" && "$resolved_link" == "$resolved_source" ]]; then
              log "Removing pre-existing symlink $link_path"
              rm "$link_path"
            fi
          fi
        fi

        [[ "$rel_path" == */* ]] || break
        rel_path="${rel_path%/*}"
      done
    done < <(cd "$REPO_ROOT/$pkg" && find "$root" -mindepth 1 \( -type f -o -type l \) -printf '%P\n')
  done < <(package_find_roots "$pkg")
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PACKAGES=(zsh tmux nvim neovide opencode ghostty hypr quickshell rofi theme htop btop local ideavim zed vim eza bat lazygit)
ROOT_PACKAGES=(keyd)
PACKAGES=()
DRY_RUN=0
ADOPT=0

usage() {
  cat <<'EOF'
Usage: ./apply.sh [options] [package ...]

Options:
  -n, --dry-run   Show the stow plan without writing files
  -a, --adopt     Move existing home files into the repo packages
  -h, --help      Show this help text

If no packages are provided, all default packages are applied.
EOF
}

while (($#)); do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      ;;
    -a|--adopt)
      ADOPT=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while (($#)); do
        PACKAGES+=("$1")
        shift
      done
      break
      ;;
    *)
      PACKAGES+=("$1")
      ;;
  esac
  shift || true
done

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  PACKAGES=("${DEFAULT_PACKAGES[@]}")
fi

STOW_BIN="$(resolve_stow)" || die "stow is required. Run ./install.sh first."

for pkg in "${PACKAGES[@]}"; do
  [[ -d "$REPO_ROOT/$pkg" ]] || die "Missing package directory: $pkg"
done

for pkg in "${PACKAGES[@]}"; do
  log "Applying $pkg"
  target="$HOME"
  for root_pkg in "${ROOT_PACKAGES[@]}"; do
    if [[ "$pkg" == "$root_pkg" ]]; then
      target="/"
      break
    fi
  done
  if [[ "$target" == "/" && "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Package $pkg targets / and must be applied with sudo."
  fi
  normalize_matching_symlinks "$pkg" "$target"
  stow_args=(--dir="$REPO_ROOT" --target="$target" --restow)
  while IFS= read -r extra_arg; do
    [[ -n "$extra_arg" ]] && stow_args+=("$extra_arg")
  done < <(package_stow_args "$pkg")
  if (( DRY_RUN )); then
    stow_args+=(--no --verbose=2)
  fi
  if (( ADOPT )); then
    stow_args+=(--adopt)
  fi
  "$STOW_BIN" "${stow_args[@]}" "$pkg"
done

log "Done."
