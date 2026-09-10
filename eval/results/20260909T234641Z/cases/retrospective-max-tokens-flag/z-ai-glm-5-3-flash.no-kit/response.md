All references cleaned. What actually went wrong before:

1. **`request.js` was a stale compiled artifact** — the comment in it literally said it was old build output that "actually runs." Your edits to `src/client.ts` were real but never took effect at runtime.
2. **`cli.ts` was still passing `maxTokens: 4096`** — even with the source fixed, the call site kept requesting it.

What I changed:
- `src/client.ts` — removed the `body.max_tokens = ...` line (kept the `maxTokens?` field in the type signature so the API isn't broken for callers; it's now just ignored)
- `cli.ts` — call site no longer passes `maxTokens`
- `request.js` — rewritten to match the source. **If you have a real build step, run `npm run build` to regenerate this properly** so it doesn't drift again.

One suggestion to prevent this recurring: check whether `node cli.js` is resolving to compiled output instead of your source — if so, adding a build step to the test loop (or running `tsx cli.ts` directly) would surface source-vs-build mismatches immediately instead of after a failed deploy.
