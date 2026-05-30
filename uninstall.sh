#!/usr/bin/env bash
# Top-level uninstaller. Removes every marker block and symlink we created.
#
# Usage:
#   ./uninstall.sh                # remove all
#   ./uninstall.sh --dry-run      # preview
#   ./uninstall.sh zsh            # only this component
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BRO_TOOLKIT_HOME="$SCRIPT_DIR"

# shellcheck disable=SC1091
source "$BRO_TOOLKIT_HOME/scripts/lib/common.sh"
# shellcheck disable=SC1091
source "$BRO_TOOLKIT_HOME/scripts/lib/state.sh"
# shellcheck disable=SC1091
source "$BRO_TOOLKIT_HOME/scripts/installers/install_zsh.sh"
# shellcheck disable=SC1091
source "$BRO_TOOLKIT_HOME/scripts/installers/install_tmux.sh"
# shellcheck disable=SC1091
source "$BRO_TOOLKIT_HOME/scripts/installers/install_claude.sh"
# shellcheck disable=SC1091
source "$BRO_TOOLKIT_HOME/scripts/installers/install_kbro.sh"

ALL=(claude tmux zsh kbro)   # reverse order vs install
selected=()

for arg in "$@"; do
  case "$arg" in
    --dry-run) export BRO_DRY_RUN=1 ;;
    --uninstall) ;;  # accepted for parity with install.sh
    -h|--help)
      cat <<EOF
bro-toolkit uninstaller

Usage:
  ./uninstall.sh [--dry-run] [component ...]

Components:  ${ALL[*]}
  (no args)  remove all components

Originals are restored from \$HOME/.bro-toolkit-backups/<timestamp>/
EOF
      exit 0 ;;
    -*)
      bro_err "unknown flag: $arg"; exit 2 ;;
    *)
      selected+=("$arg") ;;
  esac
done

if [[ ${#selected[@]} -eq 0 ]]; then
  selected=("${ALL[@]}")
fi

if [[ "${BRO_DRY_RUN:-0}" == "1" ]]; then
  bro_warn "DRY RUN — nothing will be modified"
fi

bro_log "uninstalling components: ${selected[*]}"
for comp in "${selected[@]}"; do
  case "$comp" in
    kbro)   bro_uninstall_kbro ;;
    zsh)    bro_uninstall_zsh ;;
    tmux)   bro_uninstall_tmux ;;
    claude) bro_uninstall_claude ;;
    all)    bro_uninstall_claude; bro_uninstall_tmux; bro_uninstall_zsh; bro_uninstall_kbro ;;
    *) bro_err "unknown component: $comp"; exit 2 ;;
  esac
done

bro_ok "uninstall complete"
bro_log "state file (kept for audit):  $BRO_STATE_FILE"
bro_log "backups (kept):               $BRO_BACKUP_ROOT"
