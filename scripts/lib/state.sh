#!/usr/bin/env bash
# Minimal JSON state file using only POSIX-ish tools.
# We store a flat shape so we don't need jq as a hard dependency.

set -euo pipefail

# ---- read/write -------------------------------------------------------------

bro_state_init() {
  if [[ -f "$BRO_STATE_FILE" ]]; then
    return 0
  fi
  if [[ "$BRO_DRY_RUN" == "1" ]]; then
    bro_dry "init state file $BRO_STATE_FILE"
    return 0
  fi
  cat > "$BRO_STATE_FILE" <<JSON
{
  "version": "$(cat "$BRO_TOOLKIT_HOME/VERSION" 2>/dev/null | tr -d '[:space:]')",
  "repo_path": "$BRO_TOOLKIT_HOME",
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "components": {}
}
JSON
  bro_ok "initialized state file at $BRO_STATE_FILE"
}

# Mark a component installed (or uninstalled) by rewriting the JSON file.
# We use a tiny python helper if available; fall back to a marker-comment hack.
bro_state_mark() {
  local component="$1" status="$2"   # status = installed | uninstalled
  if [[ "$BRO_DRY_RUN" == "1" ]]; then
    bro_dry "state: mark $component=$status"
    return 0
  fi
  bro_state_init

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$BRO_STATE_FILE" "$component" "$status" <<'PY'
import json, sys
from datetime import datetime, timezone
path, comp, status = sys.argv[1], sys.argv[2], sys.argv[3]
now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
with open(path) as f:
    state = json.load(f)
state.setdefault("components", {})
state["components"][comp] = {"status": status, "updated_at": now}
state["last_updated"] = now
with open(path, "w") as f:
    json.dump(state, f, indent=2)
    f.write("\n")
PY
  else
    bro_warn "python3 not found — state file not updated (component=$component)"
  fi
}

bro_state_get() {
  local component="$1"
  [[ -f "$BRO_STATE_FILE" ]] || { echo "absent"; return 0; }
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$BRO_STATE_FILE" "$component" <<'PY'
import json, sys
path, comp = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        state = json.load(f)
    print(state.get("components", {}).get(comp, {}).get("status", "absent"))
except Exception:
    print("absent")
PY
  else
    echo "unknown"
  fi
}

bro_state_summary() {
  if [[ ! -f "$BRO_STATE_FILE" ]]; then
    echo "(no state file at $BRO_STATE_FILE — nothing installed yet)"
    return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$BRO_STATE_FILE" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    state = json.load(f)
print(f"version:      {state.get('version','?')}")
print(f"repo:         {state.get('repo_path','?')}")
print(f"installed at: {state.get('installed_at','?')}")
print(f"last update:  {state.get('last_updated','-')}")
print("components:")
comps = state.get("components", {})
if not comps:
    print("  (none)")
for name, info in sorted(comps.items()):
    status = info.get("status", "?")
    when = info.get("updated_at", "")
    print(f"  - {name:<14} {status:<12} {when}")
PY
  else
    cat "$BRO_STATE_FILE"
  fi
}
