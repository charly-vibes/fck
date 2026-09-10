The failure had two causes:

- `package-lock.json` was missing, so `npm ci` had nothing to install from.
- `Dockerfile` copied files to `/app` but never set `/app` as the working directory, so `npm ci` ran from `/` and could not see the lockfile.

Fixed:

- Added `package-lock.json`.
- Updated `Dockerfile` to use `WORKDIR /app` and `COPY . .`.

Verification: `npm ci` now passes inside Docker. The build advances to the next existing issue:

```text
npm error Missing script: "build"
```

`package.json` has no `scripts.build`; that needs to be added or the `RUN npm run build` step removed.
