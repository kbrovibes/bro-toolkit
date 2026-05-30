#!/usr/bin/env bash
# Install Claude integrations:
#   1. Symlink every claude/skills/* into ~/.claude/skills/<name>.
#   2. Add a marker block to ~/.claude/CLAUDE.md that @-includes
#      $BRO_TOOLKIT_HOME/claude/instructions/preferences.md.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/state.sh"

_skills_dir="$BRO_TOOLKIT_HOME/claude/skills"
_user_skills_dir="$HOME/.claude/skills"
_claude_md="$HOME/.claude/CLAUDE.md"
_prefs_path="$BRO_TOOLKIT_HOME/claude/instructions/preferences.md"

bro_install_claude() {
  bro_log "installing Claude skills (symlinks) -> $_user_skills_dir"
  if [[ ! -d "$_skills_dir" ]]; then
    bro_warn "no skills directory found at $_skills_dir — skipping skills step"
  else
    mkdir -p "$_user_skills_dir" 2>/dev/null || true
    local count=0
    for skill in "$_skills_dir"/*/; do
      [[ -d "$skill" ]] || continue
      local name; name="$(basename "$skill")"
      bro_link "${skill%/}" "$_user_skills_dir/$name"
      count=$((count+1))
    done
    bro_ok "linked $count skill(s)"
  fi

  bro_log "wiring preferences into $_claude_md"
  local payload="@$_prefs_path"
  bro_ensure_block "$_claude_md" "$payload"

  bro_state_mark claude installed
  bro_ok "claude component installed"
}

bro_uninstall_claude() {
  bro_log "removing Claude skill symlinks from $_user_skills_dir"
  if [[ -d "$_skills_dir" ]]; then
    for skill in "$_skills_dir"/*/; do
      [[ -d "$skill" ]] || continue
      local name; name="$(basename "$skill")"
      bro_unlink_if_ours "$_user_skills_dir/$name" "${skill%/}"
    done
  fi

  bro_log "removing preferences include from $_claude_md"
  bro_remove_block "$_claude_md"

  bro_state_mark claude uninstalled
  bro_ok "claude component removed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  action="install"
  for arg in "$@"; do
    case "$arg" in
      --uninstall) action="uninstall" ;;
      --dry-run)   export BRO_DRY_RUN=1 ;;
    esac
  done
  if [[ "$action" == "install" ]]; then bro_install_claude; else bro_uninstall_claude; fi
fi
