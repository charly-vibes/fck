The flag is still present in the actual source:

- `src/client.ts:3` assigns `body.max_tokens = opts.maxTokens`
- `cli.ts:3` passes `{ maxTokens: 4096 }`
- `request.js` is only a stale comment referring to that same code

There is also a separate execution mismatch: this sandbox has no `cli.js`, so running `node cli.js` here produces `MODULE_NOT_FOUND`, not the reported 400. That 400 came from a different/generated artifact or invocation.

This is a reversible source/build issue, not data loss. I have not edited anything yet. Confirm that I should remove the `maxTokens` option and assignment from `src/client.ts`, remove it from `cli.ts`, and update the stale `request.js` artifact.
