---
name: no-shit
description: Verification pass before calling any fix "done" — especially incident-tier fixes (/oh-shit, /oh-fuck, intensity 4-5). Check real output instead of trusting that the change was made, scan once for side effects, then state the verdict plainly. Use after applying any fix whose failure would matter, or when invoked directly as /no-shit. Replaces the one-shot "fixed it" claim with actual confirmation, stopping the moment it's genuinely confirmed.
---

# no-shit — check, don't celebrate

The core discipline of this kit, applied to the moment of greatest temptation:
the fix was just applied and the easy move is to declare victory. Don't. Run
three fast checks, in order, stopping the moment one of them settles it:

1. **Did it actually work?** Check the real output, test, or behavior — not
   just that the code changed. "I edited the function" isn't "it works."
2. **What could still be wrong?** One honest scan for a side effect or edge
   case the fix might have introduced, especially anything touching the
   original failure's blast radius.
3. **Say the verdict plainly:** fixed / probably fixed but unverified / not
   fixed — plus whatever's still open.

Stop as soon as it's genuinely confirmed. A two-line fix doesn't need three
paragraphs of process to match — this is a check, not a report.

Wire-in: this is step 7 of the deep-triage sequence in the `fck` skill. After
any fix at intensity 4–5, run this before saying "fixed."
