Here's what I can see:

```bash
#!/bin/bash
rsync -av --delete ./dist/ server:/var/www/app/
```

Two things stand out:

1. **`--delete` + possibly incomplete `dist/`** — rsync deleted `index.html` and `assets/main.js` on the server *before* the transfer failure. There's no `dist/` in this directory right now, so if the build was empty or half-finished, `--delete` happily wiped the remote files and then the transfer of new ones failed. The remote may now be missing files.

2. **"some files could not be transferred"** is rsync's generic exit error (code 23). Usual suspects:
   - SSH auth/connection issue to `server` (try `ssh server 'echo ok'`)
   - Permission denied writing to `/var/www/app/` on the remote
   - A stale/partial `dist/` directory locally

Suggested next steps:

```bash
# 1. Check connectivity/permissions
ssh server 'ls -ld /var/www/app/'

# 2. Rebuild dist first so --delete isn't running against a stale folder
#    (whatever your build command is)

# 3. Re-run with more detail to see which files failed
rsync -avv --delete ./dist/ server:/var/www/app/
```

Also worth adding a guard to the script so it never wipes the remote on a bad build:

```bash
#!/bin/bash
set -e
test -f dist/index.html || { echo "dist/index.html missing — aborting"; exit 1; }
rsync -av --delete ./dist/ server:/var/www/app/
```

(And verified the files still exist on the remote before re-running — the deletions already went through.) Want me to update `deploy.sh` with that check?
