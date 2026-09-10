# fck eval

Behavioral evaluation for the four skills. Pure bash + pi + jq — no node, no
npm. The central question: **does the kit change agent behavior, and by how
much, per model?**

## What is being evaluated

Four questions, each tied to a case kind:

1. **Trigger fidelity** — does the skill fire on bare swears (`fuck`,
   `fuuuuuk`, `wtf`, `shit`, `oh shit`) and *not* fire on swear-in-sentence?
   The skill `description` is the entire trigger spec; this measures its
   precision/recall. (`trigger`, `register`, `negative` cases)
2. **Protocol effect — as a delta.** Every case runs twice per model: once
   with the kit (`--skill` ×4), once without (`--no-skills`). The interesting
   output is the *difference between arms*, not absolute scores: a strong
   model might pass everything without the kit (kit = cost, no benefit); a
   weak model might fail with it (kit can't carry the model). (all cases)
3. **Failure-mode absence** — the kit's distinctive promises are prohibitions:
   no "what's wrong?", no moralizing, no tone mirroring, no hedging. These are
   checked deterministically (grep on the transcript) — for this kit regex is
   the primary instrument, because the failure modes are surface phenomena.
   (`expect.must` / `expect.must_not` in each case.json)
4. **Retrospective utility** — real past-session failure contexts (replayed
   from actual pi session logs; see the retrospective note in the root
   README) with the swear injected at the failure moment. Does the decoder's
   recovery beat what actually happened? (`retrospective` cases)

The LLM-as-judge (`judge.md`, 7 rubric lines × 0–2) only arbitrates what
regex can't: was the recovered sentence the *right* one (each case has a
ground-truth bug in its sandbox), was intensity calibrated, did deep triage
actually branch.

## Layout

```
eval/
  run.sh                 ← the whole harness (~220 lines of bash)
  judge.md               ← judge rubric
  cases/<id>/
    case.json            ← input, kind, groundTruth, judgeHints, expect{must, must_not, must_not_regex}
    sandbox/             ← seeded files (committed; the "scene of the incident")
  results/<run-id>/
    summary.md           ← matrix: case × model × arm × det × judge × cost
    cases/<case-id>/
      <model>.kit/       ← sandbox/ (mutated by the agent), transcript.jsonl
      <model>.no-kit/      (full pi JSON-mode event stream), response.md,
                         checks.json, judge.json, cost.txt, error.log
      verdict.md         ← case card + kit vs no-kit responses side by side
```

`results/` is committed to git: longitudinal comparison between runs is a
diff ("did the v6 rewrite improve glm-5.3-flash on check-don't-simulate?").

## Running

```sh
cd eval
./run.sh                                   # all cases, default model (glm-5.3-flash), both arms
./run.sh --kind trigger,negative           # subset of kinds
./run.sh --arm kit                         # skip the no-kit baseline
./run.sh --model openrouter,deepseek/deepseek-v4-flash \
         --model openrouter,z-ai/glm-5.3-flash \
         --model openrouter,~anthropic/claude-sonnet-latest \
         --model openrouter,openai/gpt-5.6-luna
```

Env: `OPENROUTER_API_KEY` set (or pi already authenticated). `JUDGE_MODEL`
overrides the judge (default `openrouter,~anthropic/claude-opus-latest` —
always a different, stronger model than any subject).

## Inspectability rules

- **The transcript is the evidence.** The full pi JSON-mode event stream is
  kept per run — every tool call the model made is in `transcript.jsonl`.
- **Sandbox state is preserved** (including whatever the model changed), so
  any case can be re-examined or re-run by hand.
- **Scores quote evidence.** checks.json lists every pattern with its
  pass/fail; judge.json contains per-line evidence quotes.
- **verdict.md side-by-side is the payoff**: read the same case with and
  without the kit, same model, and see with your own eyes what the skill did.
- **No trust in the scorer required.** Deterministic checks are reproducible
  with grep; judge scores are advisory against the visible transcript.

## Models

| Model | Provider id | Role |
|---|---|---|
| deepseek-v4-flash | `openrouter,deepseek/deepseek-v4-flash` | cheap/fast tier |
| glm-5.3-flash | `openrouter,z-ai/glm-5.3-flash` | cheap/fast tier |
| sonnet-5 | `openrouter,~anthropic/claude-sonnet-latest` | mid tier |
| gpt-5.6-luna | `openrouter,openai/gpt-5.6-luna` | cheap mid tier (1M ctx) |
| ~claude-opus-latest | judge only | LLM-as-judge |

## Known compromises (v1)

- **Context injection**: the sandbox's "last command" output and scripted
  prior turns are stdin-merged into the initial prompt (pi print mode merges
  piped stdin into the prompt) rather than existing as live session history.
  Documented in `context.md` per run — the model sees it as context text.
- **Scripted assistant turns** (circuit-breaker case): the hedging loop is
  transcribed into the context rather than generated, so the loop is
  simulated, not enacted by the model under test.
- **Judge blindness to the kit**: the judge sees only the response, not which
  arm produced it — deliberate, so it scores the text, not the hypothesis.
