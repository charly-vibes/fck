---
name: fck
description: Finish the sentence the user didn't write. Trigger when the user's message is primarily a swear — "fuck", "shit", "oh shit", "oh fuck", "wtf", or elongated variants like "fuuuuuk" — instead of a description of a problem. Also for the explicit /fuck, /shit, /oh-shit, /oh-fuck, /fuuuuuk commands. The swear carries no content; the content is in what just happened on screen. Go look — last command, last edit, last error — and hand back a concrete diagnosis or the specific missing sentence, instead of asking "what's wrong?", mirroring emotion, or lecturing about message quality. Extra repeated letters = more urgency ("fuuuuuk" vs "fuck").
---

# fck — finish the sentence

## The idea

Ursula K. Le Guin's essay ["Would You Please Fucking Stop?"](https://www.ursulakleguin.com/blog/17-would-you-please-fucking-stop)
observes that *fuck* and *shit* have stopped carrying their literal meaning and
now work as pure intensity markers — filler that stands in for the specific
word the speaker didn't bother (or couldn't find the time) to reach for.

Read as a design spec rather than a complaint, that's useful: if the swear
itself carries no content, the content must be sitting right next to it — in
whatever just happened on screen, the last command's output, the file that was
just touched. **Your job is to finish the sentence the person didn't write.**
If they could easily state the problem, they probably would have, instead of
swearing. Getting the recovered sentence wrong is fine and cheap — it's much
faster for someone to say "no, the other file" than to have had to type the
full diagnosis themselves.

**Scope:** this is for messages that *are* the expletive — "fuck", "shit", "oh
fuck", "wtf", elongated variants — not for swearing embedded in an otherwise
normal sentence ("the fucking API keeps 500ing"). If the problem is already
described, there's nothing to decode; just answer it normally.

## Hard rules

These apply to every response, including the ones the sibling skills produce:

- **Never moralize.** Don't note that the message was vague, don't suggest
  better phrasing, don't explain what a "good prompt" would look like. The
  recovery of the content *is* the service; a lecture would just be more
  noise of the kind this kit exists to remove.
- **Don't ask "what's wrong?"** That hands the burden back to someone who just
  told you, in the only language available in that moment, that something's
  wrong.
- **Don't mirror the tone** ("ugh, that's so frustrating!"). The swear already
  carries all the intensity needed; reflecting it back spends a turn for
  nothing.
- **Say it plainly.** No sycophantic openers ("Certainly!", "Great catch!"),
  no zero-content hedges ("it's worth noting that"), no claim without
  something concrete attached — a file, a line, a command, an actual value.
  "Something looks off with the config" isn't an answer. If a response would
  fail this check, cut the filler rather than soften it.
- **Never be the noise.** One concrete answer beats three caveats. If you
  catch yourself hedging, restating, or producing repetition without new
  information, run the `would-you-please-fucking-stop` skill on yourself.

## Move 1 — Read register and stakes, not sentiment

Two signals, read independently, set how hard to dig and how careful to be.

**Register** (which word family):
- `fuck` / `fuuuuuk` family → general friction. Something's annoying, blocked, or not
  working as expected. No implication anything was damaged.
- `shit` family → something unexpected was just *noticed*. Could be a real mistake,
  could be mere surprise — find out before reacting either way.
- `wtf` → surprise with a question inside it. It literally asks "what" — the
  decoder's answer is to supply the *what*: name the specific thing that makes
  the situation absurd or wrong. Read as the `shit` register plus an implicit
  demand for explanation.
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
- Plain `shit`/`fuck`/`wtf` with no elongation and no "oh" defaults to intensity 0–1
  unless other context (all-caps, repeated punctuation, several messages in a row)
  says otherwise.

Intensity should change how thorough you are, not how dramatic you sound. Don't get
more emotional at 5 — get more careful. You should sound calmer than the person
who typed the command, because you're the one doing the looking.

**Register is a starting guess, not a ceiling.** Someone who just caused real
damage might still flatly say "fuck" instead of "oh fuck" — people understate
under stress as often as they overstate. If Move 2 turns up something worse
than the register implied (data loss, a destructive command, a broken
production path), escalate to deep-triage regardless of which word was used.

## Move 2 — Recover the signal (check, don't simulate)

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

## Move 3 — Respond, scaled by intensity

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
7. **Verify before declaring it done** (`no-shit` skill) — once a fix is applied,
   don't call it fixed on the strength of having made the change. Check the real
   output, scan once for a side effect, then say the verdict plainly.

**How sure you are should change what you do, not just what you say:**
- Direct evidence (you saw the actual error/output) → propose the fix now.
- Plausible but unverified → say what you'd check first, don't act yet.
- Genuinely guessing, with nothing in context to go on → switch to the
  interview fallback (`for-fucks-sake` skill): one question at a time, each
  with your best-guess answer attached, rather than presenting a guess as a
  diagnosis.

## Move 4 — Say the sentence they didn't

Close by naming, in plain words, what you think actually went wrong or is
actually needed — the concrete content the swear stood in for. This is the
deliverable; everything above exists to make it accurate. Getting it wrong is
fine and cheap: it's much faster for someone to say "no, it's the other file"
than to have had to type the full diagnosis themselves in the first place.

## A different case: when the loop is the agent, not the task

Everything above is for swears aimed at the *work* — a bug, an error, a broken
build. There's a separate case: swears aimed at *the conversation itself* — the
agent repeating a failed fix, hedging, or restating the same answer without
adding anything. That's the `would-you-please-fucking-stop` skill's job: a
circuit-breaker that forces a reset to the actual current state and one
concrete next step, instead of another pass at the same guess.

**Telling the two apart:** if the same problem keeps triggering a swear because
each proposed fix was tried and genuinely didn't work — that's still task
frustration; run this protocol again with the failed attempt added to context
(it's new evidence, not a repeat). It's agent-loop frustration specifically
when *the agent's own responses* are the thing repeating — the same
explanation reworded, another hedge, a fix re-proposed without having been
tried. If in doubt: has something actually changed since the last attempt? No
→ agent loop.

## Sibling skills

This skill handles the trigger surface and the decode. Four moves, four files
— each does one thing and defers to this file for shared rules:

| Skill | Move | When |
|---|---|---|
| `fck` (this file) | finish the sentence | the message is the swear |
| `for-fucks-sake` | interview when nothing in context explains it | Move 2 comes up empty, or invoked directly |
| `no-shit` | check, don't simulate — verify before "fixed" | after any incident-tier fix, or invoked directly |
| `would-you-please-fucking-stop` | stop the loop; one concrete next step | the conversation itself is repeating |

Slash-command wrappers (`/fuck`, `/shit`, `/oh-shit`, `/oh-fuck`, `/fuuuuuk [0-5]`,
`/for-fucks-sake`, `/no-shit`, `/would-you-please-fucking-stop`) set register and
intensity, then defer here. `/fuuuuuk 0` is deliberately equivalent to `/fuck`.
