#!/usr/bin/env bash
# Install the TMUX integration: a one-line marker block in ~/.tmux.conf that
# source-files $BRO_TOOLKIT_HOME/rc/tmux/bro.tmux.conf.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/state.sh"

bro_install_tmux() {
  local target="$HOME/.tmux.conf"
  # -q makes tmux ignore the line if the file is missing (e.g., repo not cloned yet).
  local payload="source-file -q \"$BRO_TOOLKIT_HOME/rc/tmux/bro.tmux.conf\""

  bro_log "installing tmux integration -> $target"
  bro_ensure_block "$target" "$payload"
  bro_state_mark tmux installed
  bro_ok "tmux component installed"
  bro_log "(reload running tmux sessions with:  tmux source-file ~/.tmux.conf)"
}

bro_uninstall_tmux() {
  local target="$HOME/.tmux.conf"
  bro_log "removing tmux integration from $target"
  bro_remove_block "$target"
  bro_state_mark tmux uninstalled
  bro_ok "tmux component removed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  action="install"
  for arg in "$@"; do
    case "$arg" in
      --uninstall) action="uninstall" ;;
      --dry-run)   export BRO_DRY_RUN=1 ;;
    esac
  done
  if [[ "$action" == "install" ]]; then bro_install_tmux; else bro_uninstall_tmux; fi
fi
