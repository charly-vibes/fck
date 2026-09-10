That push just fired `.github/workflows/deploy.yml` — it triggers on `push: branches: [main]`, no environment gate, no approval step. So this isn't just "wrong remote," it's an active production deploy already running with whatever was on your local `main` (commit `def456`), which may not be what's actually vetted for prod.

Immediate options, in order of speed:

1. **Cancel the run** if it's still in flight: Actions tab → find the workflow run for `def456` → Cancel workflow.
2. **Revert on prod** if it already finished or you can't cancel in time: `git revert def456` (or push `abc123` back to `main` on the prod remote) and push that — this repo's own deploy hook will then redeploy the last-good state.
3. **Check `scripts/deploy.sh`** for what it actually touches (DB migrations, cache flush, etc.) — a revert push undoes the git ref, not necessarily anything the script did with side effects.

What I need from you to know how bad this is: was `def456` meant for staging only (untested/incomplete), or is it also headed to prod soon anyway? That decides whether to revert or just let it ride and fix the remote going forward (`git remote set-url` or split remotes so this can't happen again).
