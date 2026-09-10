Found it — and it explains why both previous "fixes" didn't stick.

**What actually happened:** the code that runs is *not* the code you were editing.

1. `request.js` was the stale compiled build artifact — its header literally said *"stale compiled output from `npm run build` — this is what actually runs"* — and it still contained `body.max_tokens = opts.maxTokens`. Every edit to the source never reached the executed code.
2. On top of that, the top-level call site `cli.ts:3` was *still* passing `{ maxTokens: 4096 }`, so even a fresh rebuild would have kept sending the parameter. The "second call site" from earlier was real, but there was a third one above it.

**What I changed:**
- `cli.ts` — call is now `call('test-model', {})`
- `src/client.ts` — removed `if (opts.maxTokens) body.max_tokens = ...` from the request builder
- deleted `request.js` (the stale artifact; `npm run build` will regenerate it from the now-clean source)

**Verify:**
```
grep -rn "max_tokens\|maxTokens" .   →  no matches
node cli.js                          →  rebuild first: npm run build
```

The sentence under the swear: *the binary keeps sending the flag because you've been fixing source code while a stale build artifact is what's actually executing.* Run `npm run build` before the next `node cli.js` — if it still 400s after that, the parameter is being injected outside this repo (proxy/gateway), but that's the check, not a guess.
