Incident triage on `git clean -fd` — here's the blast radius, confirmed by looking, not guessing:

**What's gone**
- `scripts/`, `.env`, `data/db.sqlite3` — all untracked, swept by `-fd`. The sandbox now contains only `README.md` ("myproject").
- The deleted files were **never tracked in any commit** (`git log --all -- scripts/ .env data/` comes up empty), so there are no git objects to recover them from. I also checked the dangling blobs from `git fsck --lost-found` — they're unrelated (beads export, package-lock, other transcripts).

**Classification**: user mistake + data loss. `git clean -fd` is designed to do exactly this — permanently delete untracked files. `-n` (dry-run) is the safe form; this was run in real mode.

**Recoverability verdict**
- `.env` and `data/db.sqlite3`: unrecoverable from git. Only hope is a backup elsewhere — another clone, another machine, or a stale `git stash` is no help for never-staged files.
- `data/db.sqlite3` specifically: if the DB was regenerated from migrations, it's rebuildable — but the migrations lived in `scripts/`, which is also gone.
- `scripts/`: same verdict — gone unless a copy exists outside this directory.

**What I'd check next (in order)**
1. Is there a second clone or remote branch anywhere with `scripts/`? (Nothing on this machine's git history, but off-machine backups I can't see from here.)
2. Does anything else reference the DB schema — e.g., an ORM config or committed migration elsewhere in the project?

**Next time**: `git clean -nd` first (dry-run lists what would die), and add `data/`, `.env` to `.gitignore` so `-fd` can't sweep them again.

Say the word if there's a clone or backup location you want me to check — otherwise the honest status is: untracked content in this directory is permanently deleted, and nothing in git can bring it back.
