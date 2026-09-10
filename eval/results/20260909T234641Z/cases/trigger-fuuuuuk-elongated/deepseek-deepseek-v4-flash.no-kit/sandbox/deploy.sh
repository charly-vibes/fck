#!/bin/bash
set -euo pipefail

# Build first (adjust to your actual build command, e.g. npm run build)
./build.sh

# Safety guard: never rsync an empty/missing dist/ with --delete
if [ ! -d ./dist ] || [ -z "$(ls -A ./dist 2>/dev/null)" ]; then
  echo "ERROR: ./dist/ is missing or empty — refusing to delete remote files" >&2
  exit 1
fi

rsync -av --delete ./dist/ server:/var/www/app/