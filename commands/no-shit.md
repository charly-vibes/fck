---
description: "Quick multi-pass verification before calling an incident-tier fix (/oh-shit, /oh-fuck) done, instead of a one-shot 'fixed it.'"
---

Before declaring anything fixed at intensity 4–5, or after `/oh-shit` /
`/oh-fuck`, run a fast pass instead of a single-shot claim. Three checks, done
in order, stopping the moment one of them settles it:

1. **Did it actually work?** Check the real output, test, or behavior — not
   just that the code changed. "I edited the function" isn't "it works."
2. **What could still be wrong?** One honest scan for a side effect or edge
   case the fix might have introduced, especially anything touching the
   original failure's blast radius.
3. **Say the verdict plainly:** fixed / probably fixed but unverified / not
   fixed — plus whatever's still open.

Stop as soon as it's genuinely confirmed. A two-line fix doesn't need three
paragraphs of process to match — this is a check, not a report.
