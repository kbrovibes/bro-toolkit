#!/usr/bin/env bash
# Install the ZSH integration: a one-line marker block in ~/.zshrc that
# sources $BRO_TOOLKIT_HOME/rc/zsh/bro.zsh. All real logic lives in bro.zsh.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/state.sh"

bro_install_zsh() {
  local target="${ZDOTDIR:-$HOME}/.zshrc"
  local payload="[ -f \"$BRO_TOOLKIT_HOME/rc/zsh/bro.zsh\" ] && source \"$BRO_TOOLKIT_HOME/rc/zsh/bro.zsh\""

  bro_log "installing zsh integration -> $target"
  bro_ensure_block "$target" "$payload"
  bro_state_mark zsh installed
  bro_ok "zsh component installed"
}

bro_uninstall_zsh() {
  local target="${ZDOTDIR:-$HOME}/.zshrc"
  bro_log "removing zsh integration from $target"
  bro_remove_block "$target"
  bro_state_mark zsh uninstalled
  bro_ok "zsh component removed"
}

# Allow direct invocation: ./install_zsh.sh [--uninstall] [--dry-run]
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  action="install"
  for arg in "$@"; do
    case "$arg" in
      --uninstall) action="uninstall" ;;
      --dry-run)   export BRO_DRY_RUN=1 ;;
    esac
  done
  if [[ "$action" == "install" ]]; then bro_install_zsh; else bro_uninstall_zsh; fi
fi
