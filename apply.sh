#!/usr/bin/env bash
set -euo pipefail

log() { printf '[apply] %s\n' "$*"; }
die() { printf '[apply] ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }
os_is_mac() { [[ "$(uname -s)" == Darwin ]]; }
os_is_arch() { [[ -f /etc/os-release ]] && grep -qi '^ID=arch' /etc/os-release; }

detect_mode() {
  if os_is_mac; then
    printf 'darwin\n'
    return 0
  fi

  if os_is_arch; then
    printf 'arch\n'
    return 0
  fi

  return 1
}

resolve_mode() {
  local requested="${1:-auto}"

  case "$requested" in
    auto)
      detect_mode || die "Could not auto-detect mode for this host. Use --mode arch or --mode darwin."
      ;;
    arch|darwin)
      printf '%s\n' "$requested"
      ;;
    *)
      die "Unsupported mode: $requested (expected arch or darwin)."
      ;;
  esac
}

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

list_contains() {
  local needle="$1"
  shift

  local item
  for item in "$@"; do
    [[ "$item" == "$needle" ]] && return 0
  done

  return 1
}

package_find_roots() {
  local pkg="$1"

  case "$pkg" in
    ghostty)
      if [[ "$MODE" == "darwin" ]]; then
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
      if [[ "$MODE" == "darwin" ]]; then
        printf '%s\n' "--ignore=^\\.config($|/)"
      else
        printf '%s\n' "--ignore=^Library($|/)"
      fi
      ;;
  esac
}

package_target() {
  local pkg="$1"

  if list_contains "$pkg" "${ROOT_PACKAGES[@]}"; then
    printf '/\n'
  else
    printf '%s\n' "$HOME"
  fi
}

package_supported_in_mode() {
  local pkg="$1" mode="$2"

  if list_contains "$pkg" "${COMMON_PACKAGES[@]}"; then
    return 0
  fi

  case "$mode" in
    arch)
      list_contains "$pkg" "${ARCH_PACKAGES[@]}" || list_contains "$pkg" "${ARCH_EXTRA_PACKAGES[@]}"
      ;;
    darwin)
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

set_default_packages() {
  PACKAGES=("${COMMON_PACKAGES[@]}")

  case "$MODE" in
    arch)
      PACKAGES+=("${ARCH_PACKAGES[@]}")
      ;;
    darwin)
      :
      ;;
  esac
}

normalize_matching_symlinks() {
  local pkg="$1" target="$2"
  local rel rel_path link_path source_path resolved_link resolved_source root root_path seen_file

  seen_file="$(mktemp)"

  while IFS= read -r root; do
    root_path="$REPO_ROOT/$pkg"
    [[ "$root" == "." ]] || root_path="$root_path/$root"
    [[ -d "$root_path" ]] || continue

    while IFS= read -r rel; do
      rel="${rel#./}"
      rel_path="$rel"

      while [[ -n "$rel_path" && "$rel_path" != "." ]]; do
        if ! grep -Fqx -- "$rel_path" "$seen_file"; then
          printf '%s\n' "$rel_path" >> "$seen_file"
          link_path="$target/$rel_path"
          source_path="$root_path/$rel_path"

          if [[ -L "$link_path" && -e "$source_path" ]]; then
            resolved_link="$(canonical_path "$link_path" 2>/dev/null || true)"
            resolved_source="$(canonical_path "$source_path" 2>/dev/null || true)"
            if [[ -n "$resolved_link" && "$resolved_link" == "$resolved_source" ]]; then
              if (( DRY_RUN )); then
                log "Would remove pre-existing symlink $link_path"
              else
                log "Removing pre-existing symlink $link_path"
                rm "$link_path"
              fi
            fi
          fi
        fi

        [[ "$rel_path" == */* ]] || break
        rel_path="${rel_path%/*}"
      done
    done < <(cd "$root_path" && find . -mindepth 1 \( -type f -o -type l \) -print)
  done < <(package_find_roots "$pkg")

  rm -f "$seen_file"
}

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_PACKAGES=(zsh tmux nvim neovide opencode ghostty htop btop ideavim zed vim eza bat lazygit)
ARCH_PACKAGES=(hypr niri dank quickshell rofi theme local)
ARCH_EXTRA_PACKAGES=(keyd)
ROOT_PACKAGES=(keyd)
PACKAGES=()
MODE="auto"
DRY_RUN=0
ADOPT=0

usage() {
  cat <<'EOF'
Usage: ./apply.sh [--mode arch|darwin] [options] [package ...]

Options:
  --mode MODE     Override auto-detected mode (arch or darwin)
  -n, --dry-run   Show the stow plan without writing files
  -a, --adopt     Move existing home files into the repo packages
  -h, --help      Show this help text

If no packages are provided, the defaults for the resolved mode are applied.
Explicit package requests fail if the package is unsupported in that mode.
EOF
}

while (($#)); do
  case "$1" in
    --mode)
      shift || die "--mode requires a value."
      (($#)) || die "--mode requires a value."
      MODE="$1"
      ;;
    --mode=*)
      MODE="${1#*=}"
      ;;
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

MODE="$(resolve_mode "$MODE")"

if [[ ${#PACKAGES[@]} -eq 0 ]]; then
  set_default_packages
fi

STOW_BIN="$(resolve_stow)" || die "stow is required. Run ./install.sh first."

for pkg in "${PACKAGES[@]}"; do
  [[ -d "$REPO_ROOT/$pkg" ]] || die "Missing package directory: $pkg"
  package_supported_in_mode "$pkg" "$MODE" || die "Package $pkg is not supported in $MODE mode."
done

log "Resolved mode: $MODE"

for pkg in "${PACKAGES[@]}"; do
  log "Applying $pkg"
  target="$(package_target "$pkg")"

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
