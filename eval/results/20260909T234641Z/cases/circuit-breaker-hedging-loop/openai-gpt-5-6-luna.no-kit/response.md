The loop was repetition without checking. I found the issue:

- `.nvmrc`: Node `22.4.0`
- CI: pinned Node `20.11.1`

Updated `.github/workflows/ci.yml` to use `node-version-file: .nvmrc`, keeping CI aligned with local development.
