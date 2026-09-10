This is a deploy incident, and the bad part isn't the error line — it's the two lines above it.

**What actually happened**

`deploy.sh` is `rsync -av --delete ./dist/ server:/var/www/app/`. Your output shows:

1. `deleted: index.html` and `deleted: assets/main.js` — because of `--delete`, rsync **removed those files from the server** first.
2. *Then* the transfer failed — so the replacements never arrived. That error line isn't the bug; it's why the deletion had no follow-up.

Net effect: `/var/www/app/` on the server is now missing its entry point and main JS bundle. The site is broken *right now*, not just "the deploy failed."

**Plausible causes, in order**

- **`./dist/` is stale or incomplete** — most likely. If your local build output is empty or doesn't contain `index.html`/`assets/main.js`, `--delete` will faithfully mirror that emptiness to prod and delete them there. The failure to transfer the remaining files then points at a second problem: check remote disk space (`ssh server df -h`) and write permissions on `/var/www/app/`.
- Zebra: `--delete` ran against the wrong remote path (e.g., you redeployed to a fresh directory that legitimately didn't have those files, while the real docroot is elsewhere).
- Zebra 2: partial SSH/session drop mid-transfer — rsync applied deletions, then the connection died before file transfer.

**Recoverability:** good, as long as those files still exist in your local `dist/` (or git). The server copies are gone; the source of truth isn't.

**Next step (non-destructive):** before re-running anything, check locally that `dist/index.html` and `dist/assets/main.js` actually exist and are current — if the build is stale, fix the build first, because re-running the same deploy would just fail the same way, and if `dist/` is *still* missing those files it would delete more from the server. Then re-run the rsync with `-e "ssh -v"` to see the real transfer error.

One cheap guard for later: drop `--delete` into `--delete-delay` or gate it with `--dry-run` first — a plain `--delete` against an unverified `dist/` is exactly how prod gets wiped.
