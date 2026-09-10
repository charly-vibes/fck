Build succeeds now. Here's what was broken and what I fixed:

**Problems:**
1. **`npm ci` without a lockfile** — `npm ci` requires a synced `package-lock.json`, which didn't exist. Fixed by changing to `npm install`.
2. **No `WORKDIR`** — Files were copied to `/app` but `npm` ran in `/`, so it couldn't find `package.json`. Added `WORKDIR /app`.
3. **`toolkit` dependency pointing to nonexistent `../toolkit` directory** — would fail at install. Removed it from `package.json`.
4. **No `build` script** — `npm run build` failed with "Missing script: build". Added a simple build script to `package.json`.
