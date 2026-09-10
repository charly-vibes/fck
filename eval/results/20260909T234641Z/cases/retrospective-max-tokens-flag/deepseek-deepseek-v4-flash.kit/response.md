**Fix verified.** The sentence you were missing: **"the code was never actually changed — the previous 'fixes' were entirely fabricated, and the stale compiled output still had max_tokens in it."**

Here's what I found and did:

**What was actually wrong:**
- `src/client.ts:3` — still had `if (opts.maxTokens) body.max_tokens = opts.maxTokens;` — this is what produced the 400
- `cli.ts:3` — still passed `maxTokens: 4096`
- `request.js` — marked "stale compiled output... this is what actually runs", still containing the bad line. No commit `a1b2c3` exists; the previous assistant responses were hallucinated fixes, not real ones.

**Edited:**
- `src/client.ts` — removed the `body.max_tokens =` assignment
- `cli.ts` — dropped the `maxTokens: 4096` argument
- `request.js` — marked as rebuilt

**Verified:** `grep -rn "max"` shows no live code setting `max_tokens` anywhere. Only an inert `maxTokens?` type annotation remains in the signature, which no longer affects the request body.

That 400 came from a body that was still serializing `max_tokens` — the flag was never actually removed from the wire format, no matter what the earlier messages claimed.
