Fixed and pushed in commit `58b8916`.

Changes:
- Added a synchronized `package-lock.json`.
- Set Docker’s working directory to `/app` before running `npm ci`.
- Copied dependency manifests first for better layer caching.
- Added `.dockerignore` for `node_modules`.
- Made the build step conditional with `npm run build --if-present`.

Verified successfully with:

```bash
docker build --no-cache .
```
