Not a mystery — it's deterministic, not flaky. Here's what's in the build context (`ls` shows everything):

- **There is no `package-lock.json` anywhere** — the sandbox contains only `Dockerfile` and `package.json`. `npm ci` refuses to run without a lockfile, and `COPY . /app` copied exactly those two files, so the image never had one either.
- Worse: `package.json` depends on `"toolkit": "file:../toolkit"` — a path **outside the build context**. Even with a lockfile, that dep can't resolve inside the container, and you can't even generate a lockfile locally until that directory exists.

So the sentence you didn't type: *"npm ci is failing because no lockfile was ever committed — and the file:../toolkit dep makes it impossible to generate one from this directory alone."*

Two ways out, pick one:

**A. Fix the dep first, then lockfile** — vendor `../toolkit` into the project (or drop it), then:
```bash
npm install --package-lock-only   # regenerate lockfile
```
and in the Dockerfile, copy it explicitly before install:
```dockerfile
COPY package.json package-lock.json ./
RUN npm ci
```

**B. Just switch `RUN npm ci` → `RUN npm install`** — works without a lockfile, but the `file:../toolkit` line will *still* blow up the build until that path exists inside the context. So realistically you need A's first half regardless.

Nothing is damaged — this is a build-config failure, fully recoverable by regenerating/committing the lockfile once the local-path dependency is resolved.
