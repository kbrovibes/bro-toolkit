#!/usr/bin/env bash
# Smoke test: install --dry-run → status → uninstall --dry-run.
# Runs against a sandbox HOME so it never touches the real one.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SANDBOX="$(mktemp -d -t bro-smoke.XXXXXX)"
trap 'rm -rf "$SANDBOX"' EXIT

export HOME="$SANDBOX"
export BRO_STATE_FILE="$SANDBOX/.bro-toolkit-state.json"
export BRO_BACKUP_ROOT="$SANDBOX/.bro-toolkit-backups"

# Seed minimal dotfiles so the installer has something to modify.
touch "$SANDBOX/.zshrc"
touch "$SANDBOX/.tmux.conf"
mkdir -p "$SANDBOX/.claude"
touch "$SANDBOX/.claude/CLAUDE.md"
mkdir -p "$SANDBOX/.local/bin"

green=$'\033[32m'; red=$'\033[31m'; reset=$'\033[0m'
pass() { printf "%s[pass]%s %s\n" "$green" "$reset" "$*"; }
fail() { printf "%s[fail]%s %s\n" "$red" "$reset" "$*"; exit 1; }

echo "=== sandbox: $SANDBOX ==="

# --- dry-run install: must not write to dotfiles ---
"$REPO_ROOT/install.sh" --dry-run >/dev/null
grep -qF "BRO-TOOLKIT-MANAGED" "$SANDBOX/.zshrc"      && fail "dry-run wrote to .zshrc"
grep -qF "BRO-TOOLKIT-MANAGED" "$SANDBOX/.tmux.conf"  && fail "dry-run wrote to .tmux.conf"
pass "dry-run install was inert"

# --- real install ---
"$REPO_ROOT/install.sh" >/dev/null
grep -qF "BRO-TOOLKIT-MANAGED" "$SANDBOX/.zshrc"     || fail "marker block missing in .zshrc"
grep -qF "BRO-TOOLKIT-MANAGED" "$SANDBOX/.tmux.conf" || fail "marker block missing in .tmux.conf"
grep -qF "BRO-TOOLKIT-MANAGED" "$SANDBOX/.claude/CLAUDE.md" || fail "marker block missing in .claude/CLAUDE.md"
[[ -L "$SANDBOX/.local/bin/kbro" ]]               || fail "kbro symlink missing"
[[ -L "$SANDBOX/.claude/skills/pull" ]]           || fail "pull skill symlink missing"
pass "install touched all expected files"

# --- re-install must be idempotent ---
before_zsh="$(wc -l < "$SANDBOX/.zshrc")"
"$REPO_ROOT/install.sh" >/dev/null
after_zsh="$(wc -l < "$SANDBOX/.zshrc")"
[[ "$before_zsh" == "$after_zsh" ]] || fail "re-install changed .zshrc line count ($before_zsh -> $after_zsh)"
pass "re-install is idempotent"

# --- status ---
"$REPO_ROOT/bin/kbro" status | grep -qE "zsh\s+installed"    || fail "status: zsh not marked installed"
"$REPO_ROOT/bin/kbro" status | grep -qE "tmux\s+installed"   || fail "status: tmux not marked installed"
"$REPO_ROOT/bin/kbro" status | grep -qE "claude\s+installed" || fail "status: claude not marked installed"
"$REPO_ROOT/bin/kbro" status | grep -qE "kbro\s+installed"   || fail "status: kbro not marked installed"
pass "kbro status reports all four components installed"

# --- uninstall ---
"$REPO_ROOT/uninstall.sh" >/dev/null
grep -qF "BRO-TOOLKIT-MANAGED" "$SANDBOX/.zshrc"     && fail "marker block still in .zshrc after uninstall"
grep -qF "BRO-TOOLKIT-MANAGED" "$SANDBOX/.tmux.conf" && fail "marker block still in .tmux.conf after uninstall"
grep -qF "BRO-TOOLKIT-MANAGED" "$SANDBOX/.claude/CLAUDE.md" && fail "marker block still in .claude/CLAUDE.md after uninstall"
[[ ! -L "$SANDBOX/.local/bin/kbro" ]]               || fail "kbro symlink still present after uninstall"
[[ ! -L "$SANDBOX/.claude/skills/pull" ]]         || fail "pull skill symlink still present"
pass "uninstall removed every touchpoint"

echo
echo "all smoke tests passed."
