# fck

A tiny agent skill for decoding what a user actually needs when they express
frustration through swearing — "fuck", "shit", "oh shit", "oh fuck", or
elongated variants like "fuuuuuk".

Inspired by Ursula K. Le Guin's essay
["Would You Please Fucking Stop?"](https://www.ursulakleguin.com/blog/17-would-you-please-fucking-stop)
and a model-steering reference on prompt-architecture techniques.

## The idea

Le Guin's essay argues that *fuck* and *shit* have gone semantically hollow —
people reach for them instead of finding the actual word for what's wrong. Read
as a spec instead of a complaint, that's exploitable: if the swear itself carries
no content, the content is sitting right next to it, in whatever just happened.
So instead of an agent asking "what's wrong?" when someone types "fuck" or "oh
shit," it should go look — at the last command, the last edit, the last error —
and hand back a diagnosis, not a question.

Swear *intensity* becomes a free signal too: elongating the word ("fuuuuuk") or
escalating the register ("oh fuck" vs "fuck") tells the agent how much to
investigate and how careful to be before acting, without the person having to
say "this is urgent" or "please double-check before you touch anything."

The steering-technique reference maps onto this directly:

- **System 2 Attention** — strip the expletive, look at what surrounds it.
- **Chain-of-Thought** — trace cause → alternates → fix for moderate cases.
- **Tree/Graph-of-Thought** — branch across multiple root causes before acting,
  reserved for high-intensity/high-stakes moments.
- **Positive constraint framing** — close with a concrete answer, not another
  question.

## Install

With [skills.sh](https://skills.sh) (works with Claude Code, Cursor, Codex,
Amp, opencode, and other agent CLIs that support skills):

```sh
npx skills add charly-vibes/fck
```

Install globally with `-g`, or pick a specific agent with `-a` (e.g.
`npx skills add charly-vibes/fck -g -a claude-code`).

## What's in this kit

```
skills/
  fck/
    SKILL.md        ← the core protocol; auto-triggers on natural language
                       like "fuck", "fuuuuuk", "shit", "oh shit", "oh fuck"
commands/
  fuck.md                          ← /fuck        (intensity 0–1, quick check)
  shit.md                          ← /shit        (assess before reacting)
  oh-shit.md                       ← /oh-shit     (intensity 4–5, deep triage)
  oh-fuck.md                       ← /oh-fuck     (intensity 5, deep triage)
  fuuuuuk.md                       ← /fuuuuuk [0-5]  (explicit tunable dial)
  would-you-please-fucking-stop.md ← /would-you-please-fucking-stop
                                       (meta: agent is looping/hedging — reset,
                                       don't re-guess)
  for-fucks-sake.md                ← /for-fucks-sake
                                       (nothing in context to go on — interview
                                       instead of guessing)
  no-shit.md                       ← /no-shit
                                       (verify an incident-tier fix before
                                       calling it done)
```

The skill (`SKILL.md`) is what the skills CLI installs — it auto-triggers on
typed frustration, no slash command needed. The `commands/` directory contains
optional slash-command wrappers for environments that load commands from
`.claude/commands/` (Claude Code): drop them in at the project or user level.
Each file's name becomes the command name. You can use either independently, or
both together — the commands are thin wrappers around the same protocol
described in `SKILL.md`.

## The escalation ladder

| Trigger | Register | Default intensity |
|---|---|---|
| `fuck` | friction | 0 |
| `fuuuuuk` (u's counted, capped) | friction, scaled | 0–5 |
| `shit` | noticed something | 0–1, assess first |
| `oh shit` | alarm | 4–5 |
| `oh fuck` | alarm | 5 |
| `/fuuuuuk [n]` | explicit dial | n (default 3) |

Intensity should only ever change *how much the agent checks before answering*
— never how dramatic it sounds back. That's the whole point: it should sound
calmer than the person who typed the command, because it's the one doing the
looking.

`/would-you-please-fucking-stop` sits outside this ladder — it's not about task
frustration, it's about the agent itself repeating a failed fix or hedging
instead of committing to an answer. It resets to current state and forces one
concrete next step instead of another guess.

## Notes for contributors

Everything stays advisory-only and lightweight on purpose. Techniques borrowed
along the way (from the
[incitaciones](https://charly-vibes.github.io/incitaciones/) prompt library):
"check, don't simulate" (DDx debugging), the zebra requirement and anchoring
check (RCA-diagnostician), the interview fallback (Grill Me), the Step 4
filler checklist (anti-slop-prose audit), and the verification pass
(condensed from Universal Rule of 5). Formal report templates and scoring
tables were deliberately left out — that would defeat the point of a kit meant
to answer a one-word swear fast.

## License

[CC0 1.0 Universal](./LICENSE) — public domain. Do whatever, no attribution
required.
