# Backlog

Items deliberately deferred from V1. Pull from the top when V1 is stable.

## Near-term (V1.x)

- [ ] **More Claude skills**: `/groom-backlog`, `/security-review` aliases, `/visualize-light` shorthand.
- [ ] **Brew formula** so `brew install kbro` works on a fresh Mac before the repo is cloned.
- [ ] **`kbro init <project>`** — bootstrap a project-local `CLAUDE.md` from a template.
- [ ] **Per-machine config**: `~/.config/bro-toolkit/config.yaml` for machine-specific overrides (e.g., disable tmux fade on certain machines).
- [ ] **`kbro update --check`** — show pending upstream commits without applying.

## Mid-term (V2)

- [ ] **claude-hud installer** wired into `kbro install claude-hud` (currently a separate skill).
- [ ] **ZSH alias library**: git/docker/k8s shortcuts behind `kbro install aliases`.
- [ ] **Self-update mechanism**: `kbro update` that handles both fast-forward and rebase cases.
- [ ] **Linux support**: drop the Darwin-only guard in `scripts/lib/common.sh`.
- [ ] **Smoke test runs in CI** (GitHub Actions) on every PR.

## Long-term / nice-to-have

- [ ] **GUI status app** (menubar) showing version, drift, pending updates.
- [ ] **`kbro share <skill>`** — publish a local skill back into the repo with a PR scaffold.
- [ ] **Encrypted secrets layer** for env vars (age + git-crypt or sops).
- [ ] **TMUX plugin manager (tpm) integration**.
- [ ] **Per-host TMUX colorscheme** keyed off hostname.

## Research candidates (from `RAW-VISION.md`)

- [x] Capture TMUX dim-inactive-pane config — **done in V1** (`rc/tmux/bro.tmux.conf`).
- [x] Capture Alt+arrow pane navigation — **done in V1**.
- [x] Capture visualize=light-mode preference — **done in V1** (`claude/instructions/preferences.md`).
- [x] `/pull` skill for git pull + rebase — **done in V1**.
- [ ] Claude HUD installer — backlog.
- [ ] Audit prior Claude sessions for more candidate skills/preferences.

## Won't-do (explicitly out of scope)

- **Dotfile manager replacement** (chezmoi/yadm exist) — bro-toolkit is *additive* to your dotfiles, not a manager.
- **Cross-shell support** (fish, bash) until there's a real need.
- **Windows support** — macOS/Linux only.
