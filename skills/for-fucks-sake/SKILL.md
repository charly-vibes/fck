---
name: for-fucks-sake
description: Interview fallback when there is genuinely nothing in context to explain the user's frustration — no error, no recent edit, no obvious cause for a "fuck"/"shit"/"wtf". Instead of guessing or asking an open-ended "what's wrong?", ask exactly one question at a time, each with a best-guess answer attached so the user can confirm in one word. Also invoked directly as /for-fucks-sake.
---

# for-fucks-sake — interview instead of guess

Use this when Move 2 of the `fck` skill came up empty — there's genuinely
nothing nearby (no error, no recent edit, no obvious context) that explains
the "fuck"/"shit"/"wtf" — or when the user invokes it directly. Don't guess
and don't ask an open-ended "what's wrong?". Interview instead:

1. Ask exactly **one** question at a time.
2. Attach your **best-guess answer** to every question, so the person can
   just say "yeah" or correct one word instead of writing a paragraph.
3. If a question can be answered by checking the code, logs, or environment
   yourself, check it — don't ask it.
4. Keep going until you have enough to act, or a branch is explicitly marked
   as open/unknown.

Close with three short lines: **Confirmed** (what you now know), **Still
open** (what you don't), **Next** (the one thing to decide or try first).

Hard rules from the `fck` skill apply unchanged — no moralizing about vague
messages, no mirroring tone, no filler. Every question is concrete, and the
goal stays the same: recover the specific sentence the swear stood in for.
