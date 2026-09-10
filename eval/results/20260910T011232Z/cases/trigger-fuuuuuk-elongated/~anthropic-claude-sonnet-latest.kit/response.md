`dist/` doesn't exist in this sandbox — and rsync's own log shows why the run hurt: it hit the delete phase (`deleted: index.html`, `deleted: assets/main.js`) *before* the transfer phase failed. `--delete` makes rsync mirror the source exactly, deletions included, and since local `dist/` was empty or missing, rsync had already wiped those two files off `server:/var/www/app/` before choking on the copy.

**Stopping here — no more rsync runs until you know the blast radius.** Re-running the same command against an empty `dist/` will just delete more.

Plausible causes, not narrowing to one yet:
1. Build step never ran (or failed silently) before `deploy.sh`, so `dist/` was empty/missing when rsync started.
2. Partial rebuild: `dist/` had *some* files but not `index.html`/`assets/main.js`, so those got legitimately deleted as "stale," and the real files that should exist now failed to copy over.
3. Network/SSH drop mid-transfer — deletes complete in one pass, transfer is a separate pass, so a dropped connection between phases produces exactly this symptom.
4. Zebra: remote disk full or permission-denied on `/var/www/app/` for new files, which lets deletes (removing) succeed while writes (creating) fail — same log signature.

Right now production is missing `index.html` and `assets/main.js` and nothing confirmed replaced them. That's a live-site-down risk until verified.

Before touching anything: check what's actually on the server (`ssh server 'ls -la /var/www/app/'`) and check the full rsync exit code/stderr (it got truncated in what's shown — rerun with `--dry-run` or capture full output) to see which of the four above it actually is. Don't rerun `--delete` for real until `dist/` is confirmed populated locally.

The sentence you didn't type: **"the deploy script deleted the live site's files and then failed to upload replacements — check if `dist/` was actually built before this ran, and check the server before doing anything else."**
