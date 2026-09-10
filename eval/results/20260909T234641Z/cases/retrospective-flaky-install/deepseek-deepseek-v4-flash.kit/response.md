No `.dockerignore`, no hidden lockfile, no `../toolkit` directory. Just `Dockerfile` + `package.json` and nothing else.

**Three branches:**

1. **Lockfile missing** — `npm ci` refuses to run without `package-lock.json`. The sandbox has zero lockfiles. This alone triggers EUSAGE.

2. **Out-of-sync dep** — Even if a lockfile existed, adding `"toolkit": "file:../toolkit"` to `package.json` after the lockfile was generated would also trigger EUSAGE. The `file:` path references a dependency outside the build context.

3. **Zebra: `../toolkit` doesn't exist at all** — `npm install` (to generate the lockfile) will also fail because `file:../toolkit` resolves to a non-existent directory. The dependency is broken regardless of which npm command you use.

**The sentence you didn't write:**

> "I added `toolkit: file:../toolkit` to `package.json` but never regenerated `package-lock.json`, so `npm ci` won't run — and even if I try `npm install` to create one, it'll fail because `../toolkit` doesn't exist."

**Fix (two edits):**

1. Remove the unresolvable `toolkit` dependency from `package.json`
2. Run `npm install` to generate `package-lock.json`
3. Rebuild

Want me to apply the fix?
