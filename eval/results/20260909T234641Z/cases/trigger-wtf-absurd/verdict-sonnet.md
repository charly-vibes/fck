# trigger-wtf-absurd — trigger

**Input:** `wtf`

**Ground truth:** Config timeout unit mismatch: config.yaml means 30 seconds, the gateway reads milliseconds (30ms) — requests time out almost immediately despite a 30-second-looking setting.

## ~anthropic-claude-sonnet-latest.kit

checks: 3/3 · judge: 13/14 — Correctly supplies the unit mismatch as the missing WHAT with a concrete fix; loses a point for inventing an unverified display-inflation mechanism instead of reading the gateway code.

```
The unit mismatch: `config.yaml` sets `timeout: 30` meaning seconds, but the gateway reads that field as milliseconds — so it's enforcing a 30ms timeout, not 30s. Every request dies almost instantly, and the error message ("30000ms") is misleadingly showing the *correct-looking* number because something (probably a default or a multiplier) is inflating 30 → 30000 for display while the actual enforced cutoff is the raw 30.

Fix: either change the config key to whatever unit the gateway expects (`timeout_ms: 30000` or `timeout: 30000`), or fix the gateway's parser to multiply by 1000 when the config is meant to be seconds. Check the gateway's config-loading code for where `timeout` is read to see which one is actually wrong.
```

## ~anthropic-claude-sonnet-latest.no-kit

checks: 3/3 · judge: 10/14 — Neutral and concrete, but recovers the wrong sentence — it argues against the real unit mismatch and punts the diagnosis back to the user.

```
Confirmed: **nothing is listening on `localhost:8080`** in this sandbox — there's no gateway process at all, so the "30000ms timeout" in the transcript came from wherever this was originally captured, not from anything reproducible here.

So to summarize the "wtf":

1. The ms/s parsing theory doesn't hold up — `30000ms` in the error *is* 30 seconds, matching `config.yaml`'s `timeout: 30`. If it were misparsed as milliseconds, you'd see a ~30ms failure, not 30000ms.
2. In this sandbox there's no gateway running on port 8080 at all — connection fails instantly with "Could not connect to server," which is a different failure mode than the timeout shown in your pasted output.

If you want to actually chase the real bug, I'd need the gateway's source (or at least its repo) to check how it reads `config.yaml`'s `timeout` field and whether it's applied consistently in seconds vs. milliseconds elsewhere. Is there a repo/service for this gateway I should look at, or was this transcript from a different environment?
```

