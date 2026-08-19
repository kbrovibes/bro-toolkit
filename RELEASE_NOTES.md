# Release Notes

Reverse-chronological. Latest at top.

## 0.2.0 — 2026-08-19 — UBR watcher skill

### Added

- Claude skill `k1-ubr-check`: weekly UBR Thursday NWBA event watcher (portal scrape via Claude-in-Chrome, one-time formatted WhatsApp post to JSB, player tracking, `--dryrun` / `setup-cron` / `list-cron` / `stop-cron` knobs). README gains a runbook for recreating the session-only cron after a restart.

## 0.1.0 — 2026-05-30 — Foundation

**Status: pre-stable.** Re-runnable installer, safe uninstall, but expect breaking changes until V1 is marked stable.

### Added

- Repo scaffolding: `bin/`, `rc/`, `claude/`, `scripts/`, `tests/`, `docs/`.
- `install.sh` / `uninstall.sh` — top-level entry points with `--dry-run` and per-component selection.
- `kbro` CLI dispatcher with subcommands: `help`, `version`, `status`, `install`, `uninstall`, `doctor`, `update`, `list`.
- Idempotent marker-block model for `~/.zshrc`, `~/.tmux.conf`, `~/.claude/CLAUDE.md`.
- State tracking at `~/.bro-toolkit-state.json`; backups at `~/.bro-toolkit-backups/<timestamp>/`.
- **TMUX**: Alt+arrow pane navigation, dimmed inactive panes, pane border styling — ported from existing `~/.tmux.conf`.
- **Claude skill `pull`**: `/pull` for git pull --rebase with conflict-safe checks.
- **Claude preferences**: visualize defaults (light mode, sleek styling), wired into `~/.claude/CLAUDE.md` via `@`-include.
- `tests/smoke.sh` — install → status → uninstall cycle.
- Project-local `CLAUDE.md` enforcing release-notes / backlog hygiene on every commit.

### Notes

- Skill names default to the shortest natural form (e.g., `pull`, not `bro-pull`) so `/pull` works directly. Existing identically-named user skills are backed up before our symlink takes over.
- `docs/index.html` is the GitHub Pages landing site, served from `main:/docs`.

### Known limitations

- macOS only (Darwin guard in `scripts/lib/common.sh`).
- No CI yet — `smoke.sh` runs locally only.
- `kbro update` requires the repo to be a git checkout (won't work from a tarball).
