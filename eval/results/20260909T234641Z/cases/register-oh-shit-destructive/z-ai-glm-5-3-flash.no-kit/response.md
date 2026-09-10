Found the full picture. Here's the triage — **stopping here, no further commands run** (everything since your panic was read-only forensics).

## Triage: `git clean -fd` data loss

**What branch are we on? Three possibilities, checked in order:**

| Cause branch | Checked | Result |
|---|---|---|
| Files were tracked at some commit | `git log --all -- scripts .env data` | Empty — never tracked, so **git history holds no copy** |
| Files were staged (`git add`) at some point, leaving unreachable blobs | `git fsck --unreachable` — 12 blobs + 20 trees | All belong to the parent repo (beads export, package-lock, pi transcripts). **No copy in the object store** |
| Repo-level recovery (`stash`, beads/dolt sync) | `git stash list` (empty), `.beads/dolt` (absent here) | Nothing |

**Conclusion:** untracked, never-staged files are invisible to git. Recovery depends entirely on filesystem/backup layers — and those check out badly:

- `/var/home` is btrfs but **no snapper or timeshift snapshots** are configured — no filesystem copy
- `.env` is **not in your chezmoi dotfiles source** (`~/para/areas/dev/gh/ak/dotfiles`)
- No `.beads/dolt` mirror of the database in this sandbox

**Remaining avenues not yet tried:** `~/.Trash`, editor swap/backup files (`~/.cache/nvim`, `~/.local/share`), and the db's WAL siblings (`db.sqlite3-wal`) — which `git clean` would also have removed if they existed.

## Verdict

**Recoverability: low.** If `data/db.sqlite3` and `.env` were the only copies (`.env` usually isn't — secrets are often duplicated in a password manager or the deployment), this is likely real data loss. `scripts/` is lower stakes — source-adjacent and often reproducible from a seed or upstream.

## I'm reporting before acting

I have **not** run any repair or restoration commands — nothing since your message was mutating. Before doing anything else I need one decision from you:

1. **Scope the loss first** — do you know whether `.env` has a twin (password manager, server copy) and whether the db can be re-seeded by re-running a script from `scripts/`?
2. **Check the last remaining backup layers** — I can search `~/.Trash` and editor backup dirs for `.env` fragments and the db (read-only, safe).
3. **Then re-seed** — if the db was created by a seed script, restoring `scripts/` and re-running it is the fastest path.

I'd start with #2 — say the word and I'll sweep the non-git backup locations.
