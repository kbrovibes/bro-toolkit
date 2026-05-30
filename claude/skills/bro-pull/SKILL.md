---
name: bro-pull
description: Update the current git checkout safely. Runs `git pull --rebase --autostash` from the repo root, refusing to proceed if there are unresolved conflicts or detached HEAD. Use when the user says "pull", "/pull", "/bro-pull", "rebase from origin", or "update this repo".
---

# bro-pull

Bring the current git checkout up to date with its upstream — without losing local work or stomping a half-finished rebase.

## When to use

Trigger this skill when the user asks to:

- "pull", "/pull", "/bro-pull"
- "rebase against main/origin"
- "update this checkout"
- "sync with upstream"

If you're not in a git repo, say so and stop.

## What to do

Run these checks **in order**. Stop and report at the first failure — never push through.

1. **Confirm git repo.** `git rev-parse --git-dir` — if it fails, say "not a git repo" and stop.
2. **Confirm clean-enough working tree.** `git status --porcelain` — if any output, decide:
   - Untracked files only: fine, proceed.
   - Modified/staged files: tell the user, then proceed with `--autostash`.
   - Unresolved merge/rebase markers (`<<<<<<<`): **stop** and tell the user to resolve first.
3. **Check current branch.** `git symbolic-ref --short HEAD` — if detached HEAD, stop and say so.
4. **Check upstream is set.** `git rev-parse --abbrev-ref --symbolic-full-name @{u}` — if missing, ask the user which remote/branch to pull from (don't guess).
5. **Pull with rebase + autostash:** `git pull --rebase --autostash`.
6. **Summarize.** Report: starting commit → ending commit (short SHAs), number of commits applied, any auto-stash that was reapplied.

## What not to do

- Don't `git pull` without `--rebase` — the user wants linear history.
- Don't `git reset --hard` to "recover" from a failed rebase. Stop and tell the user.
- Don't push.
- Don't switch branches.
- Don't run `git gc` or any other "cleanup."

## Output format

Keep it tight — 3 lines max on success:

```
pulled <N> commit(s) from <upstream>
  <oldsha>..<newsha>  on <branch>
  (autostash: <reapplied|n/a>)
```

On failure, one line of cause + one suggested next step.
