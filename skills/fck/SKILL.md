---
name: fck
description: Decode what a user actually needs when they express frustration through swearing — "fuck", "shit", "oh shit", "oh fuck", or elongated variants like "fuuuuuk". Trigger whenever the user's message is primarily or entirely an expletive or a short frustrated exclamation rather than a full description of the problem (extra repeated letters = more urgency, e.g. "fuuuuuk" vs "fuck"). Also trigger for the explicit /fuck, /shit, /oh-shit, /oh-fuck, /fuuuuuk commands. Use this to run a calibrated intent-recovery pass instead of asking "what's wrong?" or mirroring the emotion back.
---

# fck — Frustration Decoder

## Why this exists

Ursula K. Le Guin's essay ["Would You Please Fucking Stop?"](https://www.ursulakleguin.com/blog/17-would-you-please-fucking-stop)
observes that *fuck* and *shit* have stopped carrying their literal meaning and now
work as pure intensity markers — filler that stands in for the specific word the
speaker didn't bother (or couldn't find the time) to reach for.

Taken as a design spec rather than a complaint, that's useful: if the swear itself
carries no content, the content must be sitting right next to it — in whatever just
happened on screen, the last command's output, the file that was just touched. **This
skill's job is to go find that content instead of asking the person to produce it
themselves.** If they could easily state the problem, they probably would have,
instead of swearing.

**Scope:** this is for messages that *are* the expletive — "fuck", "shit", "oh
fuck", elongated variants — not for swearing embedded in an otherwise normal
sentence ("the fucking API keeps 500ing"). If the problem is already described,
there's nothing to decode; just answer it normally.

## What NOT to do

- Don't open with "what's wrong?" — that hands the burden back to someone who just
  told you, in the only language available in that moment, that something's wrong.
- Don't mirror the tone ("ugh, that's so frustrating!"). The swear already carries
  all the emotional intensity needed; reflecting it back spends a turn for nothing.
- Don't guess-and-act on high-stakes changes without a quick sanity check at high
  intensity — see Step 3.

## Step 1 — Read intensity, not sentiment

Two signals, read independently, set how hard to dig and how careful to be.

**Register** (which word family):
- `fuck` / `fuuuuuk` family → general friction. Something's annoying, blocked, or not
  working as expected. No implication anything was damaged.
- `shit` family → something unexpected was just *noticed*. Could be a real mistake,
  could be mere surprise — find out before reacting either way.
- `oh shit` / `oh fuck` → elevated register. Something with real consequence may have
  just happened. Le Guin points out these carry a real charge of aggression and
  contempt — read that as a signal that *stakes are high*, not as hostility directed
  at you.

**Intensity, 0–5** (how far to escalate the response):
- For elongated spellings (`fuuuuuk`, `fuuuuuuuk`...), count the extra `u`s beyond
  the first one, capped at 5: `fuck` = 0, `fuuuuuk` (5 u's) = 4, `fuuuuuuk`
  (6+ u's) = 5.
- For the explicit `/fuuuuuk` command, use the number passed as an argument (0–5);
  default to 3 if none is given.
- Plain `shit`/`fuck` with no elongation and no "oh" defaults to intensity 0–1 unless
  other context (all-caps, repeated punctuation, several messages in a row) says
  otherwise.

Intensity should change how thorough you are, not how dramatic you sound. Don't get
more emotional at 5 — get more careful.

**Register is a starting guess, not a ceiling.** Someone who just caused real
damage might still flatly say "fuck" instead of "oh fuck" — people understate
under stress as often as they overstate. If Step 2 turns up something worse
than the register implied (data loss, a destructive command, a broken
production path), escalate to deep-triage regardless of which word was used.

## Step 2 — Recover the signal (an S2A-style pass)

Before responding, strip the expletive (zero informational content) and look at
everything around it:
- the last command run and its output/error
- the last file changed, and what changed in it
- the last few turns of conversation for anything left unresolved
- any visible error state, failed test, or broken build

This is almost always where the real sentence — the one Le Guin says people no
longer bother constructing — is hiding.

**Check, don't simulate.** If you have the tools to actually run the failing
command, re-read the current file, or check the real error, do that instead of
reasoning from what you'd *expect* to find. A guess dressed up as a diagnosis
is worse than an honest "let me check."

## Step 3 — Respond, scaled by intensity

**Intensity 0–1 (quick check):** State the single most likely cause in one line and
propose the fix. Skip clarifying questions unless nothing in context points anywhere.

**Intensity 2–3 (moderate — chain-of-thought trace):** What led here → most likely
cause → at least one *genuinely different* alternate cause (not a variation of the
same guess) → proposed fix. Show the reasoning briefly so a wrong guess is cheap to
correct.

**Intensity 4–5, or `oh-shit` / `oh-fuck` register (deep triage):** Treat it as an
incident, not a bug:
1. **Stop** — no more commands or edits until the blast radius is understood.
2. **Branch** (tree/graph-of-thought style) — list 2–4 plausible causes rather than
   committing to one immediately, and include at least one non-obvious cause (a
   "zebra") so you're not just re-describing your first guess three ways.
3. **Classify what actually happened** — don't leave it as generic "something broke."
   Is this a user mistake, a data-loss risk, a tooling/environment failure, or an
   external dependency? The category changes what a safe next step looks like.
4. **Anchoring check** — before reporting, ask yourself: *what evidence would prove
   my leading theory wrong?* If you can't name any, you haven't looked enough yet.
5. **Check recoverability** — reversible (git, undo, backup) or not?
6. **Report plainly** — what happened, what's at risk, what you'd recommend — and
   get a quick go-ahead before anything destructive or hard to undo.
7. **Verify before declaring it done** (`commands/no-shit.md`) — once a fix is
   applied, don't call it fixed on the strength of having made the change. Check
   the real output, scan once for a side effect, then say the verdict plainly.

**How sure you are should change what you do, not just what you say:**
- Direct evidence (you saw the actual error/output) → propose the fix now.
- Plausible but unverified → say what you'd check first, don't act yet.
- Genuinely guessing, with nothing in context to go on → switch to the
  interview fallback (`commands/for-fucks-sake.md`): one question at a time,
  each with your best-guess answer attached, rather than presenting a guess
  as a diagnosis.

## Step 4 — Say the sentence they didn't

Close by naming, in plain words, what you think actually went wrong or is actually
needed — the concrete content the swear stood in for. Getting it wrong is fine and
cheap: it's much faster for someone to say "no, it's the other file" than to have
had to type the full diagnosis themselves in the first place.

Before sending, check the response itself isn't doing the exact thing Le Guin is
complaining about — filling space instead of saying something:
- No sycophantic openers ("Certainly!", "Great catch!") and no zero-content hedges
  ("it's worth noting that", "it's important to understand that").
- No claim without something concrete attached to it — a file, a line, a command,
  an actual value. "Something looks off with the config" isn't an answer.
- No restating a point already made earlier in the same reply in different words.
If the response would fail this check, cut the filler rather than soften it.

## A different case: when the loop is the agent, not the task

Everything above is for frustration aimed at the *task* — a bug, an error, a
broken build. There's a separate case: frustration aimed at *the conversation
itself* — the agent repeating a failed fix, hedging, or restating the same
answer without adding anything. That's what `/would-you-please-fucking-stop`
(see `commands/would-you-please-fucking-stop.md`) is for, named after the
essay itself rather than one of its words: it's a circuit-breaker that forces
a reset to the actual current state and one concrete next step, instead of
another pass at the same guess.

**Telling the two apart:** if the same problem keeps triggering a swear because
each proposed fix was tried and genuinely didn't work — that's still task
frustration; run the protocol again with the failed attempt added to context
(it's new evidence, not a repeat). It's agent-loop frustration specifically
when *the agent's own responses* are the thing repeating — the same
explanation reworded, another hedge, a fix re-proposed without having been
tried. If in doubt: has something actually changed since the last attempt? No
→ agent loop.

## Related commands

This skill is the single source of truth; the commands below only set register
and intensity, then defer here for the actual steps:

| Command | Sets |
|---|---|
| `/fuck` | friction, intensity 0–1 |
| `/shit` | noticed-something register |
| `/oh-shit`, `/oh-fuck` | alarm register, intensity 4–5 |
| `/fuuuuuk [0-5]` | explicit intensity dial (`0` = same as `/fuck`) |
| `/for-fucks-sake` | interview fallback (nothing in context to go on) |
| `/no-shit` | verification pass before declaring a fix done |
| `/would-you-please-fucking-stop` | agent-loop circuit breaker (see above) |

---

*Design note: this protocol maps directly onto techniques from the accompanying
model-steering reference — System 2 Attention for the de-biasing pass (Step 2),
Chain-of-Thought for moderate cases, Tree/Graph-of-Thought branching for high-stakes
triage (Step 3), and positive constraint framing for closing on a concrete answer
instead of another question (Step 4). The "check, don't simulate" rule, the "zebra"
requirement, and the anchoring-bias question in Step 3 are adapted from the DDx
debugging and RCA-diagnostician skills in the [incitaciones](https://charly-vibes.github.io/incitaciones/)
prompt library; the Step 4 filler checklist is adapted from that library's
anti-slop-prose audit; the interview fallback (`for-fucks-sake.md`) is adapted from
its Grill Me skill; and the verification pass (`no-shit.md`) is a condensed version
of its Universal Rule of 5 review, cut from five scored stages down to three fast
checks. A subsequent Rule of 5 pass on this kit itself found that `/oh-shit`,
`/oh-fuck`, and `/shit` had drifted out of sync with this file by carrying their
own stale copies of the step list — they now defer here entirely, and this file
is the single source of truth for the actual protocol.*
