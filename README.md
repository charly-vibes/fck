# fck

**The only agent skills you need.** Four of them.

fck is a small kit for coding agents, built as a reading of Ursula K. Le
Guin's essay
["Would You Please Fucking Stop?"](https://www.ursulakleguin.com/blog/17-would-you-please-fucking-stop) —
applied to how we talk to AI.

## The argument

Le Guin's complaint isn't swearing — she admits she can't stop saying "oh
shit" herself. It's the collapse of the effort to find the right word: the
novelist who writes "too fucking beautiful to fucking believe" instead of
looking at the sunset and saying what it did. The swear is the moment someone
*stops constructing the sentence* and expects the noise to carry the meaning
anyway.

AI makes that abdication rational. You don't need the precise word anymore
because the model will guess. When it guesses wrong, you don't write the
sentence — you say "no, not that" and roll again. Low-content utterance →
confident guess → "no" → another guess. Both sides strip-mine language; the
expectation that the machine will do everything right is the same failure as
expecting *fuck* to carry the meaning.

This kit is that essay, transposed: the swear is a sentence the person didn't
finish, and **the agent's job is to finish it** — go look at what just
happened, and hand back the specific content the swear stood in for.

## The rule about pointing fingers

The agent never moralizes. It doesn't note that the message was vague, doesn't
teach "prompt engineering", doesn't explain what a good prompt would look
like. The recovery of the content *is* the service — the critique is implicit
in the craft, the same way Le Guin indicts the usage and not the speaker (she
counts herself among the offenders).

The stricter standard is pointed the other way: at the agent. No hedging, no
repetition without new information, no claims without a check, no filler
standing in for the specific thing that needs saying. The machine models the
compromise the human has dropped. That's the whole ethic.

## The four skills

Everything wrong with AI-assisted work reduces to four missing moves. One
skill per move:

| Skill | Move | Le Guin line it embodies |
|---|---|---|
| [`fck`](skills/fck/SKILL.md) | finish the sentence | "actual words become the shit that happens in between saying fuck" |
| [`for-fucks-sake`](skills/for-fucks-sake/SKILL.md) | interview, don't guess | — when nothing in context explains the swear |
| [`no-shit`](skills/no-shit/SKILL.md) | check, don't celebrate | "I don't think there are meaningless swearwords; they wouldn't work if they were meaningless" — the content is recoverable, but only if you actually look |
| [`would-you-please-fucking-stop`](skills/would-you-please-fucking-stop/SKILL.md) | stop the loop | the title — repetition without content |

`fck` is the core: it auto-triggers on bare swears ("fuck", "shit", "oh
shit", "oh fuck", "wtf", elongated variants like "fuuuuuk"), reads *register
and stakes* from the word choice, and scales how much it checks before
answering — never how dramatic it sounds. The other three are callable
standalone and are wired into its protocol as fallbacks.

## Install

### pi (coding agent)

One install gets you all four skills **and** the `/fuck`-style slash commands:

```sh
pi install git:github.com/charly-vibes/fck
```

Or per-project (shared with your team via `.pi/settings.json`):

```sh
pi install -l git:github.com/charly-vibes/fck
```

### skills.sh (Claude Code, Cursor, Codex, Amp, opencode, …)

```sh
npx skills add charly-vibes/fck
```

Install globally with `-g`, or pick a specific agent with `-a`.

### What works where

| Channel | Auto-trigger skills | Slash commands |
|---|---|---|
| pi (`pi install git:…`) | ✅ all four | ✅ (prompt templates: `/fuck`, `/oh-shit`, …) |
| skills.sh (`npx skills add charly-vibes/fck`) | ✅ all four | ❌ (skills CLI installs skills only) |
| Claude Code manual | copy `skills/*/` → `.claude/skills/` | copy `prompts/*.md` → `.claude/commands/` |

The slash commands are thin wrappers around the same protocols — safe to skip
if your harness auto-triggers the skills from typed swears.

## What's in this kit

```
skills/
  fck/                            ← core: finish the sentence
    SKILL.md                        auto-triggers on "fuck", "fuuuuuk", "shit",
                                    "oh shit", "oh fuck", "wtf"
    references/design.md            design notes + version history
  for-fucks-sake/SKILL.md         ← interview fallback (nothing in context to go on)
  no-shit/SKILL.md                ← verify before calling a fix done
  would-you-please-fucking-stop/
    SKILL.md                       ← agent-loop circuit breaker
prompts/                          ← pi prompt templates / Claude Code slash commands
  fuck.md        shit.md        oh-shit.md     oh-fuck.md
  fuuuuuk.md     for-fucks-sake.md    no-shit.md
  would-you-please-fucking-stop.md
eval/                             ← behavioral eval harness (see eval/README.md)
```

## The escalation ladder

| Trigger | Register | Default intensity |
|---|---|---|
| `fuck` | friction | 0 |
| `fuuuuuk` (u's counted, capped) | friction, scaled | 0–5 |
| `shit` | noticed something | 0–1, assess first |
| `wtf` | surprise with a question inside it | 0–1, supply the "what" |
| `oh shit` | alarm | 4–5 |
| `oh fuck` | alarm | 5 |
| `/fuuuuuk [n]` | explicit dial | n (default 3) |

Intensity should only ever change *how much the agent checks before answering*
— never how dramatic it sounds back. It should sound calmer than the person
who typed the command, because it's the one doing the looking.

`/would-you-please-fucking-stop` sits outside this ladder — it's not about the
task, it's about the agent itself repeating a failed fix or hedging instead of
committing to an answer.

## Evaluating it

The `eval/` directory runs the kit through pi's SDK against multiple models
(deepseek-v4-flash, glm-5.3-flash, sonnet-5, gpt-5.6-luna, …) and scores
whether they actually follow the protocol — trigger on bare swears, never ask
"what's wrong?", never moralize, escalate triage at high intensity. See
[eval/README.md](eval/README.md).

## Notes for contributors

Everything stays advisory-only and lightweight on purpose. Techniques borrowed
from the [incitaciones](https://charly-vibes.github.io/incitaciones/) prompt
library: "check, don't simulate" (DDx debugging), the zebra requirement and
anchoring check (RCA-diagnostician), the interview fallback (Grill Me), the
filler checklist (anti-slop-prose audit), and the verification pass
(condensed from Universal Rule of 5). Formal report templates and scoring
tables were deliberately left out — that would defeat the point of a kit meant
to answer a one-word swear fast. Version history and design rationale live in
[skills/fck/references/design.md](skills/fck/references/design.md).

## License

[CC0 1.0 Universal](./LICENSE) — public domain. Do whatever, no attribution
required.
