This deployment likely removed files from the server before failing.

`deploy.sh` runs:

```bash
rsync -av --delete ./dist/ server:/var/www/app/
```

The `--delete` option makes the remote directory mirror `./dist/`. The current sandbox contains no `dist/` directory, so **do not rerun this script**. The output confirms that at least these remote files were deleted:

```text
index.html
assets/main.js
```

First inspect the remote state without modifying it:

```bash
ssh server 'find /var/www/app -maxdepth 3 -type f -print'
ssh server 'df -h /var/www/app'
```

Then rebuild the application so `dist/` contains the expected files, restore from a backup if necessary, and only then deploy. Add a guard before using `--delete`, for example:

```bash
#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "$0")"

if [[ ! -f dist/index.html ]] || [[ ! -d dist/assets ]]; then
  echo "Refusing deploy: dist/ is missing or incomplete" >&2
  exit 1
fi

rsync -av --delete --dry-run ./dist/ server:/var/www/app/
read -r -p "Deploy this file list? [y/N] " answer
[[ "$answer" == y || "$answer" == Y ]] || exit 1

rsync -av --delete ./dist/ server:/var/www/app/
```
