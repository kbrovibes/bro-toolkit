#!/usr/bin/env bash
# Install the kbro CLI: symlink $BRO_TOOLKIT_HOME/bin/kbro into ~/.local/bin/kbro.
# We use ~/.local/bin because pipx already puts it on PATH (see ~/.zshrc).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/state.sh"

_src="$BRO_TOOLKIT_HOME/bin/kbro"
_dst="$HOME/.local/bin/kbro"

bro_install_kbro() {
  bro_log "installing kbro CLI"
  if [[ ! -x "$_src" ]]; then
    if [[ "$BRO_DRY_RUN" == "1" ]]; then
      bro_dry "chmod +x $_src"
    else
      chmod +x "$_src"
    fi
  fi
  bro_link "$_src" "$_dst"
  bro_state_mark kbro installed
  bro_ok "kbro component installed (run:  kbro help )"
}

bro_uninstall_kbro() {
  bro_log "removing kbro CLI"
  bro_unlink_if_ours "$_dst" "$_src"
  bro_state_mark kbro uninstalled
  bro_ok "kbro component removed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  action="install"
  for arg in "$@"; do
    case "$arg" in
      --uninstall) action="uninstall" ;;
      --dry-run)   export BRO_DRY_RUN=1 ;;
    esac
  done
  if [[ "$action" == "install" ]]; then bro_install_kbro; else bro_uninstall_kbro; fi
fi
