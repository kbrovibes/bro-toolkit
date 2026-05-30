#!/usr/bin/env bash
# Shared helpers for all bro-toolkit installers.
# Source this from any installer:  source "$BRO_TOOLKIT_HOME/scripts/lib/common.sh"

set -euo pipefail

# Resolve the repo root regardless of where this is sourced from.
if [[ -z "${BRO_TOOLKIT_HOME:-}" ]]; then
  _bro_lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  BRO_TOOLKIT_HOME="$(cd "$_bro_lib_dir/../.." && pwd)"
  export BRO_TOOLKIT_HOME
fi

BRO_MARKER_BEGIN="# >>> BRO-TOOLKIT-MANAGED >>>"
BRO_MARKER_END="# <<< BRO-TOOLKIT-MANAGED <<<"
BRO_STATE_FILE="${BRO_STATE_FILE:-$HOME/.bro-toolkit-state.json}"
BRO_BACKUP_ROOT="${BRO_BACKUP_ROOT:-$HOME/.bro-toolkit-backups}"
BRO_DRY_RUN="${BRO_DRY_RUN:-0}"

# ---- platform guard ---------------------------------------------------------

bro_require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    bro_err "bro-toolkit currently supports macOS only (see BACKLOG.md for Linux support)"
    exit 1
  fi
}

# ---- logging ----------------------------------------------------------------

# Colors only on a TTY.
if [[ -t 1 ]]; then
  _BRO_C_RESET=$'\033[0m'
  _BRO_C_DIM=$'\033[2m'
  _BRO_C_GREEN=$'\033[32m'
  _BRO_C_YELLOW=$'\033[33m'
  _BRO_C_RED=$'\033[31m'
  _BRO_C_BLUE=$'\033[34m'
else
  _BRO_C_RESET=""; _BRO_C_DIM=""; _BRO_C_GREEN=""; _BRO_C_YELLOW=""; _BRO_C_RED=""; _BRO_C_BLUE=""
fi

bro_log()  { printf "%s[bro]%s %s\n" "$_BRO_C_BLUE"   "$_BRO_C_RESET" "$*"; }
bro_ok()   { printf "%s[ok]%s  %s\n" "$_BRO_C_GREEN"  "$_BRO_C_RESET" "$*"; }
bro_skip() { printf "%s[skip]%s %s\n" "$_BRO_C_DIM"    "$_BRO_C_RESET" "$*"; }
bro_warn() { printf "%s[warn]%s %s\n" "$_BRO_C_YELLOW" "$_BRO_C_RESET" "$*" >&2; }
bro_err()  { printf "%s[err]%s  %s\n" "$_BRO_C_RED"   "$_BRO_C_RESET" "$*" >&2; }
bro_dry()  { printf "%s[dry-run]%s %s\n" "$_BRO_C_YELLOW" "$_BRO_C_RESET" "$*"; }

# ---- dry-run aware action wrapper ------------------------------------------
# Usage: bro_run "description" cmd args...
bro_run() {
  local desc="$1"; shift
  if [[ "$BRO_DRY_RUN" == "1" ]]; then
    bro_dry "$desc"
    return 0
  fi
  bro_log "$desc"
  "$@"
}

# ---- backup -----------------------------------------------------------------
# Copy a file to the backup root preserving its leading path under HOME.
# Idempotent: only backs up the *first* time per session.
bro_backup_file() {
  local target="$1"
  [[ -e "$target" ]] || return 0

  local stamp="${BRO_BACKUP_STAMP:-$(date -u +%Y%m%dT%H%M%SZ)}"
  export BRO_BACKUP_STAMP="$stamp"

  local rel="${target#$HOME/}"
  local dest="$BRO_BACKUP_ROOT/$stamp/$rel"
  if [[ -e "$dest" ]]; then
    bro_skip "backup exists: $dest"
    return 0
  fi
  if [[ "$BRO_DRY_RUN" == "1" ]]; then
    bro_dry "backup $target -> $dest"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp -p "$target" "$dest"
  bro_ok "backed up: $target -> $dest"
}

# ---- marker block management ------------------------------------------------
# bro_ensure_block <file> <payload-line-1> [<payload-line-2> ...]
# Idempotent: if a marker block exists and its body matches the payload, no-op.
# Otherwise: backs up, removes any old block, appends the new one.
bro_ensure_block() {
  local file="$1"; shift
  local payload
  payload="$(printf "%s\n" "$@")"

  # Ensure file exists (touch only if it doesn't).
  if [[ ! -e "$file" ]]; then
    if [[ "$BRO_DRY_RUN" == "1" ]]; then
      bro_dry "create $file"
    else
      mkdir -p "$(dirname "$file")"
      : > "$file"
    fi
  fi

  if [[ -e "$file" ]] && bro_block_body_matches "$file" "$payload"; then
    bro_skip "marker block already current in $file"
    return 0
  fi

  bro_backup_file "$file"
  bro_remove_block "$file"

  if [[ "$BRO_DRY_RUN" == "1" ]]; then
    bro_dry "append marker block to $file"
    return 0
  fi

  {
    printf "\n%s\n" "$BRO_MARKER_BEGIN"
    printf "%s\n" "$payload"
    printf "%s\n" "$BRO_MARKER_END"
  } >> "$file"
  bro_ok "wrote marker block to $file"
}

# Return 0 if the file contains a marker block whose body equals $2.
bro_block_body_matches() {
  local file="$1"
  local expected="$2"
  [[ -f "$file" ]] || return 1

  awk -v B="$BRO_MARKER_BEGIN" -v E="$BRO_MARKER_END" '
    $0 == B { inblock = 1; next }
    $0 == E { inblock = 0; next }
    inblock { print }
  ' "$file" > "$file.bro.body.$$" 2>/dev/null || true

  local got=""
  [[ -f "$file.bro.body.$$" ]] && got="$(cat "$file.bro.body.$$")"
  rm -f "$file.bro.body.$$"

  [[ "$got" == "$expected" ]]
}

# Remove the marker block (idempotent — no-op if not present).
bro_remove_block() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  if ! grep -qF "$BRO_MARKER_BEGIN" "$file"; then
    return 0
  fi
  if [[ "$BRO_DRY_RUN" == "1" ]]; then
    bro_dry "remove marker block from $file"
    return 0
  fi
  local tmp; tmp="$(mktemp)"
  awk -v B="$BRO_MARKER_BEGIN" -v E="$BRO_MARKER_END" '
    $0 == B { inblock = 1; next }
    $0 == E { inblock = 0; next }
    !inblock { print }
  ' "$file" > "$tmp"
  # Trim any trailing blank lines we may have left behind.
  awk 'BEGIN{n=0} {lines[NR]=$0} END{for(i=NR;i>=1;i--){if(lines[i]!="")break;n++} for(i=1;i<=NR-n;i++)print lines[i]}' "$tmp" > "$tmp.2"
  mv "$tmp.2" "$file"
  rm -f "$tmp"
  bro_ok "removed marker block from $file"
}

# ---- symlink helpers --------------------------------------------------------
# Create or refresh a symlink; preserve user's existing target by backing up.
bro_link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" ]]; then
    local current; current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      bro_skip "symlink current: $dst -> $src"
      return 0
    fi
    bro_backup_file "$dst"
    if [[ "$BRO_DRY_RUN" == "1" ]]; then
      bro_dry "refresh symlink $dst -> $src"
      return 0
    fi
    rm "$dst"
  elif [[ -e "$dst" ]]; then
    bro_backup_file "$dst"
    if [[ "$BRO_DRY_RUN" == "1" ]]; then
      bro_dry "replace $dst with symlink -> $src"
      return 0
    fi
    rm -rf "$dst"
  fi

  if [[ "$BRO_DRY_RUN" == "1" ]]; then
    bro_dry "ln -s $src $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  bro_ok "linked $dst -> $src"
}

bro_unlink_if_ours() {
  local dst="$1" expected_src="$2"
  if [[ -L "$dst" ]]; then
    local current; current="$(readlink "$dst")"
    if [[ "$current" == "$expected_src" ]]; then
      if [[ "$BRO_DRY_RUN" == "1" ]]; then
        bro_dry "rm $dst"
      else
        rm "$dst"
        bro_ok "removed symlink $dst"
      fi
      return 0
    fi
    bro_warn "not removing $dst — points to $current, not $expected_src"
    return 0
  fi
  if [[ -e "$dst" ]]; then
    bro_warn "not removing $dst — not a symlink (we never managed this)"
  fi
}
