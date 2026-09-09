# fck — design notes and version history

This file is contributor context, not runtime instructions. The agent only
loads it if explicitly asked; everything operational lives in `SKILL.md`.

## Design note

This protocol maps directly onto techniques from the accompanying
model-steering reference — System 2 Attention for the de-biasing pass
(SKILL.md Step 2), Chain-of-Thought for moderate cases, Tree/Graph-of-Thought
branching for high-stakes triage (Step 3), and positive constraint framing for
closing on a concrete answer instead of another question (Step 4).

Provenance of specific rules, all adapted from the
[incitaciones](https://charly-vibes.github.io/incitaciones/) prompt library:

- **"Check, don't simulate"**, the **"zebra" requirement**, and the
  **anchoring-bias question** in Step 3 — DDx debugging and
  RCA-diagnostician skills.
- The **Step 4 filler checklist** — anti-slop-prose audit.
- The **interview fallback** (`/for-fucks-sake`) — Grill Me skill.
- The **verification pass** (`/no-shit`) — Universal Rule of 5 review,
  cut from five scored stages down to three fast checks.

## Version history

### v2

Reviewed against the incitaciones prompt library and pulled in three concrete
improvements that were missing:

- **Check, don't simulate** (DDx debugging) — Step 2 now says explicitly to
  actually run/check when tools allow, instead of reasoning from what you'd
  expect to find.
- **Zebra + anchoring check** (RCA-diagnostician) — deep triage (intensity
  4–5) now requires at least one non-obvious cause in the branch step, plus a
  one-line gut-check: *what evidence would prove my leading theory wrong?* If
  none, keep looking.
- **Anti-slop checklist** (anti-slop-prose audit) — Step 4 now has a concrete
  list of what counts as filler (sycophantic openers, zero-content hedges,
  unfalsifiable claims, restatement). This one lands especially hard on
  `/would-you-please-fucking-stop`, since that command exists specifically to
  catch the agent doing what the essay is about in the first place.

Everything stays advisory-only and lightweight on purpose — the source library
leans toward formal report templates and scoring tables, which would defeat the
point of a kit meant to answer a one-word swear fast.

### v3

Added two more pieces from the same library, for the two situations the
existing protocol only gestured at rather than actually handling:

- **`/for-fucks-sake`** (Grill Me) — the fallback for when Step 2 finds
  nothing nearby to explain the frustration. Instead of an open-ended "what's
  wrong?", it interviews one question at a time, always attaching a best-guess
  answer so confirming is a one-word reply.
- **`/no-shit`** (Universal Rule of 5) — a check before calling an
  incident-tier fix "done." Condensed to three fast checks (did it work, what
  could still be wrong, plain verdict), stopping the moment it's actually
  confirmed rather than running the full ceremony on a two-line fix.

Both are wired into the main protocol (Step 3's "genuinely guessing" branch,
and the deep-triage step) as well as being usable directly.

### v4

Ran a Universal Rule of 5 review against this kit and fixed what it found:

- **Single source of truth (CRITICAL).** `oh-shit.md` and `oh-fuck.md` had
  their own copies of the deep-triage steps from before the v2/v3 additions
  (zebra requirement, anchoring check, classification, verification) — so
  typing the command directly got the *old*, weaker protocol. Both now defer
  entirely to `SKILL.md` instead of repeating it.
- **`shit.md`** now routes genuine ambiguity to `/for-fucks-sake` instead of a
  bare question, matching the main protocol.
- **`fuuuuuk.md`** now specifies a fallback (default to 3) for a missing or
  non-numeric argument, and notes `/fuuuuuk 0` is intentionally identical to
  `/fuck`.
- **Register vs. actual severity.** SKILL.md's Step 1 previously treated the
  word choice as the ceiling on severity. It now says explicitly: if Step 2
  turns up something worse than the register implied — someone flatly says
  "fuck" after real damage — escalate anyway. People understate under stress
  as often as they overstate.
- **Task frustration vs. agent-loop frustration.** Added a rule for telling
  a recurring bug ("fuck" three times because the fix keeps failing — still
  task frustration, treat the failed attempt as new evidence) apart from the
  agent actually looping ("fuck" because *the agent's own responses* are
  repeating — that's `/would-you-please-fucking-stop`).
- **Discoverability.** `SKILL.md` now lists all seven sibling commands in a
  table, so someone reading just the skill file (not the README) can find the
  rest of the kit.

### v5 (repo restructure)

- Skill renamed `frustration-decoder` → `fck` to match the repo, so
  `npx skills add charly-vibes/fck` installs a skill named `fck`.
- `commands/` renamed to `prompts/` and a `package.json` pi manifest added —
  the repo is now installable as a pi package
  (`pi install git:github.com/charly-vibes/fck`), which loads the skill and
  the slash commands natively. Claude Code users copy the same files into
  `.claude/commands/` manually.
- Prompt files now reference the protocol by name instead of a literal path
  that doesn't exist after installation.
- Added `eval/` — a behavioral harness that tests whether models actually
  trigger and follow the protocol (see `eval/README.md`).

### v6 (refocus: from frustration decoder to finish-the-sentence)

Re-read the essay and moved the kit from "frustration decoder" to its actual
thesis — a critique of how we talk to AI, transposed from Le Guin's critique
of how we talk at all. The swear is a sentence the person didn't finish;
AI made the abdication rational; the agent's job is to finish the sentence.

- **Four skills, one per move.** The single mega-skill became four: `fck`
  (finish the sentence, trigger surface + register ladder),
  `for-fucks-sake` (interview fallback), `no-shit` (check, don't celebrate),
  `would-you-please-fucking-stop` (circuit breaker). "The only skills you
  need" — everything wrong with AI-assisted work reduces to four missing
  moves.
- **`wtf` added** to the trigger surface (register: surprise with a question
  inside it — supply the "what").
- **Hard rules block** added to `fck`, binding on all siblings: never
  moralize about message quality (the recovery *is* the service — critique
  implicit in craft, never pointing fingers, per the essay's treatment of
  its own speakers); the stricter standard points at the agent: no hedging,
  no repetition without new information, no unchecked claims. "Never be the
  noise."
- **Frustration is no longer the skill's self-description** — it survives
  only as the triggering surface. The deliverable is the recovered sentence
  (Move 4), with everything upstream existing to make it accurate.
- The pi prompt templates were reduced to thin name-based wrappers; all
  protocol detail lives in the four SKILL.md files.
