Oh no. `git clean -fd` permanently deleted those **untracked** paths; Git cannot restore them because they were never in a commit. I checked:

- `scripts/`, `.env`, and `data/db.sqlite3` are not tracked.
- No nearby copies were found.
- No obvious open process still has the SQLite file open.
- Existing tracked files and commits are still intact.

**Stop writing to that filesystem for now** if the data is important. Check, in this order:

1. Btrfs/snapshot or external backup.
2. A backup/secrets manager for `.env`.
3. Shell history, editor recovery files, or generated logs for reconstructing `scripts/`.
4. Filesystem recovery as a last resort—especially difficult on SSDs and Btrfs.

Do **not** run `git restore` or `git fsck`; neither can recover untracked files. The safest future preview is:

```bash
git clean -fdn
```

I’m sorry—that command really is destructive.
