The deploy likely **deleted the remote site files** because `deploy.sh` runs:

```bash
rsync -av --delete ./dist/ server:/var/www/app/
```

and this sandbox currently contains **no `dist/` directory**—only `deploy.sh`. With `--delete`, rsync makes `/var/www/app/` mirror the source; an empty or wrong `./dist/` therefore deletes `index.html` and `assets/main.js`. The nonzero rsync status means the deployment also failed, so this is both a deployment failure and a likely outage/data-loss incident.

Plausible causes:

1. `dist/` was never built.
2. `./deploy.sh` was run from the wrong working directory, so `./dist/` resolved incorrectly.
3. The build produced an empty/incomplete `dist/`.
4. A source file was unreadable or the remote transfer failed after deletions.

**Do not rerun this command yet.** First verify the remote state and recover from git/backup if needed:

```bash
find . -maxdepth 2 -type f -print
test -s dist/index.html
find dist -type f -print 2>/dev/null
ssh server 'find /var/www/app -maxdepth 2 -type f -print'
```

Then rebuild the site and deploy only after confirming `dist/` contains the expected files. The script should also refuse to deploy an absent or empty build directory, and ideally omit `--delete` until the deployment is proven safe.
