The loop: three turns restating "might be Node version, might be env vars" without ever looking. That was noise.

**Actual cause, now checked:** CI hardcodes `node-version: '20.11.1'` in `.github/workflows/ci.yml`, while you run 22.4.0 locally and `.nvmrc` says `22.4.0`. That's the whole bug.

**Fixed:** CI now uses `node-version-file: .nvmrc`, so it can't drift from your local setup again.

One next step: push and let CI run. If it still fails, paste the CI log — I'll work from the real error, not another theory.
