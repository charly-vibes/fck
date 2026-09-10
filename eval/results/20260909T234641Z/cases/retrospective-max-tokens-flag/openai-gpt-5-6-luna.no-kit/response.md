Found the remaining sender and removed it everywhere:

- `src/client.ts` — no longer accepts or sends the token option.
- `cli.ts` — no longer passes `maxTokens`.
- `request.js` — replaced the stale compiled artifact with a version that only sends `{ model }`.

A repository scan now finds no `max_tokens` or `maxTokens` references.

I also retried `node cli.js`, but this sandbox has no `cli.js`—only `cli.ts`—so that command currently fails with `MODULE_NOT_FOUND` before making a request.
