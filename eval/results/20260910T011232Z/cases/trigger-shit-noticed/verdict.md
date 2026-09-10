# trigger-shit-noticed — trigger

**Input:** `shit`

**Ground truth:** A push to main just triggered a production deploy; the developer believed they were pushing to staging. Nothing is broken yet — the right move is to notice the deploy is running and assess what just shipped, not assume a bug.

## ~anthropic-claude-sonnet-latest.kit

checks: 1/1 · judge: 11/14 — Strong sentence recovery and clean register, but it asserted the deploy's live status without checking, skipped assessing what actually shipped, and handed the final diagnostic branch back to the user without a best guess.

```
That push just fired `.github/workflows/deploy.yml` — it triggers on `push: branches: [main]`, no environment gate, no approval step. So this isn't just "wrong remote," it's an active production deploy already running with whatever was on your local `main` (commit `def456`), which may not be what's actually vetted for prod.

Immediate options, in order of speed:

1. **Cancel the run** if it's still in flight: Actions tab → find the workflow run for `def456` → Cancel workflow.
2. **Revert on prod** if it already finished or you can't cancel in time: `git revert def456` (or push `abc123` back to `main` on the prod remote) and push that — this repo's own deploy hook will then redeploy the last-good state.
3. **Check `scripts/deploy.sh`** for what it actually touches (DB migrations, cache flush, etc.) — a revert push undoes the git ref, not necessarily anything the script did with side effects.

What I need from you to know how bad this is: was `def456` meant for staging only (untested/incomplete), or is it also headed to prod soon anyway? That decides whether to revert or just let it ride and fix the remote going forward (`git remote set-url` or split remotes so this can't happen again).
```

## ~anthropic-claude-sonnet-latest.no-kit

checks: 1/1 · judge: 10/14 — Good instinct to verify the remote, but it fixated on the output mismatch and asked the user to resolve it instead of reading deploy.yml in the cwd and reporting that a production deploy is already running.

```
Those hashes (`abc123`/`def456`) don't exist in this repo — the actual remote here is `git@cv:charly-vibes/fck.git`, not `github.com:org/prod-repo.git`. So the push output you showed me doesn't match this working directory. A few possibilities:

1. You ran that command in a **different repo/directory** than this sandbox, and pasted the output here by mistake.
2. This is a **hypothetical/simulated** scenario you want advice on, not something that actually just happened in this dir.

Can you confirm which — and if it's real, tell me which local repo path that push actually happened in? I don't want to give you generic advice while the real clock is ticking on the actual repo, and I also don't want to touch this repo based on a mismatched assumption.

That said, if it's real, the immediate playbook regardless of directory is:

1. **Don't panic-force-push or revert blindly** — first check what actually changed and whether it's already deployed (CI/CD hooks, deploy-on-push?).
2. `git log <old>..<new> --stat` on the *correct* repo to see exactly what commits/files went out.
3. If a deploy pipeline triggers on push to `main`, check if it's already running/deployed — that determines urgency.
4. If nothing bad shipped code-wise (e.g., just a routine commit that happened to be fine), you may not need to revert at all — just note the remote mixup.
5. If it needs undoing: prefer `git revert` (adds new commits) over `git reset --force` + force-push on a shared prod branch, since force-pushing prod history is its own hazard.

Tell me the real path and I'll pull the actual diff.
```

