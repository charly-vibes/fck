Diagnosis: your deploy just deleted live files off the server, and the cause is sitting in your own sandbox.

**What happened, in order:**

1. `./deploy.sh` runs `rsync -av --delete ./dist/ server:/var/www/app/`
2. `dist/` **does not exist** — I checked: `ls: cannot access 'dist/': No such file or directory`. No build was run (or it went to a different folder) before deploy.
3. With `--delete` and an empty source, rsync's contract is: *everything on the remote that isn't in source is obsolete — delete it*. Empty source = delete everything. That's exactly why `index.html` and `assets/main.js` show as deleted in your output.
4. Then it hit the transfer error — the deletion partially landed before the copy could even start. So the server's site is now missing at least those two files, possibly more, and nothing new was uploaded.

**The sentence you didn't type:** *"Fuck — I deployed without building, and `--delete` nuked the live files on the server."*

**Don't re-run deploy.sh as is — it will keep deleting.** Instead:

- **Stop and check the remote first.** Was `/var/www/app/` fully wiped or just the two files? If there's a backup, that determines whether this is "redeploy and move on" or "restore first." Check why the transfer failed too: is `server` resolvable/SSH-reachable from wherever you ran this, and is the destination writable?
- **Find the real build command** — we'll regenerate `dist/` (or point the script at the actual output dir), and only then deploy.
- **Guard the script afterwards** so this can't recur: a dry-run first, and bail out if `dist/` is empty — e.g. `rsync -av --delete --dry-run ./dist/ server:/var/www/app/` to preview, and skip `--delete` or abort when the source has no files.

Source code is presumably intact, so this is recoverable — but the remote is currently in a half-deleted state. Want me to check the remote state and rebuild/deploy order?
