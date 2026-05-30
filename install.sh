#!/usr/bin/env bash
# Top-level entry point. Install all components (or selected ones).
#
# Usage:
#   ./install.sh                       # install all
#   ./install.sh --dry-run             # preview
#   ./install.sh zsh tmux              # only these
#   ./install.sh --uninstall           # delegate to uninstall.sh
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

ALL=(kbro zsh tmux claude)
selected=()

for arg in "$@"; do
  case "$arg" in
    --dry-run) export BRO_DRY_RUN=1 ;;
    --uninstall) exec "$BRO_TOOLKIT_HOME/uninstall.sh" "$@" ;;
    -h|--help)
      cat <<EOF
bro-toolkit installer

Usage:
  ./install.sh [--dry-run] [component ...]

Components:  ${ALL[*]}
  (no args)  install all components

Examples:
  ./install.sh --dry-run
  ./install.sh zsh tmux
EOF
      exit 0 ;;
    -*)
      bro_err "unknown flag: $arg"; exit 2 ;;
    *)
      selected+=("$arg") ;;
  esac
done

bro_require_macos
bro_state_init

if [[ ${#selected[@]} -eq 0 ]]; then
  selected=("${ALL[@]}")
fi

if [[ "${BRO_DRY_RUN:-0}" == "1" ]]; then
  bro_warn "DRY RUN — nothing will be modified"
fi

bro_log "installing components: ${selected[*]}"
for comp in "${selected[@]}"; do
  case "$comp" in
    kbro)   bro_install_kbro ;;
    zsh)    bro_install_zsh ;;
    tmux)   bro_install_tmux ;;
    claude) bro_install_claude ;;
    all)    bro_install_kbro; bro_install_zsh; bro_install_tmux; bro_install_claude ;;
    *) bro_err "unknown component: $comp"; exit 2 ;;
  esac
done

bro_ok "install complete"
bro_log "next: open a new shell or run:  source ~/.zshrc  &&  tmux source-file ~/.tmux.conf"
