# bro-toolkit zsh integration. Sourced by ~/.zshrc via a single marker block.
# Keep this file minimal — anything you'd be sad to lose should be split into
# its own file under rc/zsh/ and sourced from here.

# Resolve repo root from this file's location so the export is correct even if
# the user has moved the repo.
typeset -g BRO_TOOLKIT_HOME="${BRO_TOOLKIT_HOME:-${${(%):-%x}:A:h:h:h}}"
export BRO_TOOLKIT_HOME

# Expose bin/ on PATH (idempotent — only prepend if not already there).
if [[ ":$PATH:" != *":$BRO_TOOLKIT_HOME/bin:"* ]]; then
  export PATH="$BRO_TOOLKIT_HOME/bin:$PATH"
fi

# Pull in lightweight aliases if present.
[[ -f "$BRO_TOOLKIT_HOME/rc/zsh/aliases.zsh" ]] && source "$BRO_TOOLKIT_HOME/rc/zsh/aliases.zsh"
