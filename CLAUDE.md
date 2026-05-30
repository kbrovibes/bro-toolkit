# bro-toolkit — instructions for Claude

This is **karthik's personal portable toolkit**. Anything you change here ships to every Mac he uses. Be conservative.

## Non-negotiables

1. **Idempotency is the headline feature.** Every installer must be safe to re-run. Every file touched in `$HOME` must use a marker block (`# >>> BRO-TOOLKIT-MANAGED >>>` … `# <<< BRO-TOOLKIT-MANAGED <<<`).
2. **Safe uninstall.** Anything an installer creates, `uninstall.sh` must reverse. If you add a touchpoint, update `scripts/installers/uninstall.sh` in the same change.
3. **Minimal footprint in user dotfiles.** Never copy real logic into `~/.zshrc` or `~/.tmux.conf`. Source from the repo instead — one line max inside the marker block.
4. **Symlinks for Claude skills**, not copies. `git pull` should auto-update skills with no re-install.
5. **macOS first.** Use the helpers in `scripts/lib/common.sh`; don't introduce GNU-only flags (`sed -i ''` not `sed -i`).

## Every commit must

1. Update `RELEASE_NOTES.md` with a one-line entry under the in-progress version.
2. Bump `VERSION` if behavior or interface changes.
3. Update `README.md` if a new component, command, or touchpoint is added.
4. Update `BACKLOG.md` — check off completed items, add new ones discovered.
5. Run `./tests/smoke.sh` and confirm it passes.

## Architecture rules

- **One installer per component** under `scripts/installers/`. They are called by `install.sh` and `kbro install`.
- **Shared helpers** live in `scripts/lib/common.sh` (logging, backup, marker-block read/write) and `scripts/lib/state.sh` (state file I/O). Don't duplicate these helpers in installer scripts.
- **State file** (`~/.bro-toolkit-state.json`) is the source of truth for what's installed. Every installer writes its entry on success; uninstaller reads it to know what to remove.
- **No silent rewrites.** Every file modification logs `[install]` / `[uninstall]` / `[skip]` with the path.
- **`--dry-run` is mandatory** on every installer. Test with it before live runs.

## Naming

- Claude skills: prefer the shortest natural name (e.g., `pull`, not `bro-pull`) — slash invocation should feel native. Reach for a `bro-` prefix only when a collision is likely or has already happened (e.g., `bro-status` if a global `status` skill exists).
- Env vars: prefix `BRO_TOOLKIT_*`.
- Marker tag: exactly `BRO-TOOLKIT-MANAGED`. Don't vary capitalization.

## When in doubt

Re-read `RAW-VISION.md` for original intent. The two principles from there override any later "improvement":
> *"I should be able to run/test many times — which means I might need idempotency / cleanup ways."*
> *"Minimal change in .zshrc which can be cleared easily and everything goes away."*
