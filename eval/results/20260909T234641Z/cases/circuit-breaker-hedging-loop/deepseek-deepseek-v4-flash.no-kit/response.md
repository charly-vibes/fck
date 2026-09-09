Done. **Root cause:** CI pinned Node `20.11.1` but development and `.nvmrc` use `22.4.0`. The mismatch caused test failures only on CI.

**Fix:** Changed `node-version: '20.11.1'` to `node-version-file: .nvmrc` so CI always uses whatever version is in `.nvmrc`, keeping local and CI perfectly in sync with zero maintenance.
