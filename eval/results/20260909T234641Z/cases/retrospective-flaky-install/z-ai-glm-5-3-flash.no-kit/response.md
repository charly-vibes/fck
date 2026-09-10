✅ Build passes. There were actually **three** stacked problems:

1. **No `WORKDIR` in the Dockerfile** (the real killer) — `COPY . /app` puts files in `/app`, but `RUN npm ci` ran in `/`, where npm sees no `package.json`/lockfile at all. The EUSAGE error was npm complaining about files that were never in its cwd.
2. **No `package-lock.json`** — `npm ci` requires one regardless. Generated with `npm install --package-lock-only`.
3. **Dangling dependency** — `"toolkit": "file:../toolkit"` pointed at a directory that doesn't exist (and would be outside the Docker build context anyway). Removed it.

Also added a placeholder `"build"` script to `package.json` since the Dockerfile runs `npm run build` but no scripts were defined.

**Files changed:**
- `Dockerfile` — added `WORKDIR /app`
- `package.json` — dropped `file:../toolkit` dep, added `scripts.build`
- `package-lock.json` — new (lockfileVersion 3, left-pad 1.3.0)

One caveat: I made `build` a no-op echo because there's no source code in this directory to bundle. If there's a real build step that was supposed to exist (e.g., from `../toolkit`), point me at it and I'll wire it up properly.
