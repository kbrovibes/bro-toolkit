# bro-toolkit

Personal portable toolkit — Claude skills, ZSH/TMUX configs, and a `kbro` CLI — installable on any new Mac with one command, and fully reversible.

## Why

When I move to a new machine I want one repo to clone and one command to run. Then my Claude skills, my preferred TMUX layout, my shell helpers, and my custom CLI are all there. No drift, no forgotten dotfile snippets, no "wait, where did I put that script."

Just as important: **safe to uninstall**. Everything this toolkit adds to your `~/.zshrc`, `~/.tmux.conf`, and `~/.claude/` lives inside marker blocks or under namespaced symlinks. `./uninstall.sh` removes every trace.

## Status

| | |
|---|---|
| Version | `0.1.0` |
| Stability | **Pre-stable** — expect re-runs, breaking changes |
| Tested on | macOS (Darwin) |

## Install

```bash
git clone https://github.com/kbrovibes/bro-toolkit.git ~/claude/bro-toolkit
cd ~/claude/bro-toolkit
./install.sh                # install everything
./install.sh --dry-run      # preview without touching anything
./install.sh zsh tmux       # install only these components
```

Project page: <https://kbrovibes.github.io/bro-toolkit/>

After install, restart your shell (or `source ~/.zshrc`) and `tmux source ~/.tmux.conf`.

## Uninstall

```bash
cd ~/claude/bro-toolkit
./uninstall.sh              # remove every marker block, symlink, and PATH entry
./uninstall.sh --dry-run    # preview what would be removed
```

Originals are restored from `~/.bro-toolkit-backups/<timestamp>/`.

## What's inside (V1)

| Component | What it does | Touchpoint |
|---|---|---|
| `kbro` CLI | Dispatcher: `kbro help / status / install / uninstall / doctor / update` | symlink at `~/.local/bin/kbro` |
| ZSH config | Exports `BRO_TOOLKIT_HOME`, adds `bin/` to PATH, sources aliases | one `source` line in `~/.zshrc` |
| TMUX config | Alt+arrow pane nav, dimmed inactive panes, pane border styling | one `source-file` line in `~/.tmux.conf` |
| Claude skill `pull` | `/pull` — git pull --rebase with conflict-safe checks | symlink at `~/.claude/skills/pull` |
| Claude skill `k1-ubr-check` | UBR Thursday badminton watcher: portal scrape + WhatsApp notify (see below) | symlink at `~/.claude/skills/k1-ubr-check` |
| Claude preferences | Visualize defaults (light mode, sleek styling) | one `@`-include in `~/.claude/CLAUDE.md` |

## The kbro CLI

```
kbro                        # show help
kbro help                   # show help
kbro version                # show version
kbro status                 # show install status of each component
kbro doctor                 # diagnostics: detect drift, missing symlinks
kbro install [component]    # idempotent install (component = zsh|tmux|claude|kbro|all)
kbro uninstall              # safe uninstall
kbro update                 # git pull in repo, then re-run install
kbro list                   # list available skills and tools
```

## The UBR watcher (`/k1-ubr-check`)

Weekly automation that watches <https://my.universalbadmintonrating.com/badminton_events>
for the Thursday NWBA Bel-Red event, posts ONE formatted message to the WhatsApp group
**JSB** when registration opens (signup counts, Kiran/Vasu status, a rotating Swathi
joke line), then pauses until Saturday once both tracked players are registered. Full
spec lives in [`claude/skills/k1-ubr-check/SKILL.md`](./claude/skills/k1-ubr-check/SKILL.md).

**The cron is session-only.** It dies whenever the Claude Code session ends (laptop
restart, quit, crash) and auto-expires after 7 days. State (`~/claude/UBR/state.json`)
survives, so recreating it never double-posts.

### To recreate after a restart (the whole runbook)

1. Laptop awake, Chrome running, and in Chrome:
   - logged in to UBR (`my.universalbadmintonrating.com` — must not redirect to sign-in)
   - WhatsApp Web linked (`web.whatsapp.com` shows your chats)
2. Start a Claude Code session anywhere and keep it open (the cron lives inside it):
   ```
   claude
   /k1-ubr-check setup-cron
   ```
3. Optional sanity checks:
   ```
   /k1-ubr-check list-cron     # confirm the 5-min job exists
   /k1-ubr-check --dryrun      # sends a test message to your own WhatsApp self-chat
   ```

That's it — `setup-cron` dedupes old jobs, so it is safe to run any time you are unsure.

## How idempotency works

Every file the installer touches gets a **marker block**:

```bash
# >>> BRO-TOOLKIT-MANAGED >>>
source "$HOME/claude/bro-toolkit/rc/zsh/bro.zsh"
# <<< BRO-TOOLKIT-MANAGED <<<
```

Re-running `install.sh` is a no-op if the block is already present and correct. `uninstall.sh` removes the block and restores the file from `~/.bro-toolkit-backups/`.

Claude skills are **symlinks** into `~/.claude/skills/bro-<name>` — so `git pull` in the repo auto-updates them with no re-install.

State of what's installed is tracked in `~/.bro-toolkit-state.json`.

## Directory layout

```
bro-toolkit/
├── bin/kbro                       # dispatcher CLI
├── rc/
│   ├── zsh/bro.zsh                # sourced by ~/.zshrc
│   └── tmux/bro.tmux.conf         # sourced by ~/.tmux.conf
├── claude/
│   ├── skills/pull/               # /pull skill
│   ├── skills/k1-ubr-check/       # /k1-ubr-check UBR watcher skill
│   └── instructions/preferences.md
├── scripts/
│   ├── lib/{common,state}.sh      # shared helpers
│   └── installers/                # one script per component
├── tests/smoke.sh                 # install → status → uninstall cycle
├── install.sh  uninstall.sh
└── README.md  BACKLOG.md  RELEASE_NOTES.md  VERSION  CLAUDE.md
```

## Testing changes

```bash
./tests/smoke.sh                   # runs install --dry-run, status, uninstall --dry-run
```

This is a pre-stable project: every PR should leave `smoke.sh` passing.

## See also

- [`BACKLOG.md`](./BACKLOG.md) — what's planned but not in V1
- [`RELEASE_NOTES.md`](./RELEASE_NOTES.md) — per-version changes
- [`CLAUDE.md`](./CLAUDE.md) — instructions for Claude when editing this repo
