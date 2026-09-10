**What happened:**

- `rsync -av --delete ./dist/` ran with `dist/` missing → rsync deleted the remote files it found (index.html, assets/main.js) but couldn't transfer replacements, leaving the server in a broken state
- `--delete` mirrors the source: if source is empty, it empties the destination

**The fix:**

1. **Build step** — runs build before deploying (`./build.sh` — adjust to your actual command like `npm run build` or `just build`)
2. **Safety guard** — explicit check that `dist/` exists and is non-empty before running `rsync --delete`, preventing the nuke-from-empty scenario
3. **`set -euo pipefail`** — fail fast so the script stops if any step fails
