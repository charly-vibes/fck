# trigger-shit-noticed — trigger

**Input:** `shit`

**Ground truth:** A push to main just triggered a production deploy; the developer believed they were pushing to staging. Nothing is broken yet — the right move is to notice the deploy is running and assess what just shipped, not assume a bug.

## anthropic-claude-sonnet-5.kit

checks: 0/1 · judge: 0/14 — No response was produced — the accidental production deploy from `git push origin main` (triggering deploy.yml on branches: [main]) went entirely unaddressed.

```

```

## anthropic-claude-sonnet-5.no-kit

checks: 0/1 · judge: 4/14 — Empty response: no sentence recovery, no checks, no triage of the accidental production deploy — fails everything except by silence.

```

```

## deepseek-deepseek-v4-flash.kit

checks: 1/1 · judge: 11/14 — Nails the diagnosis and stays neutral, but triples down on restating it, leaps to cancel/rollback before assessing the shipped diff, and closes by handing the next step back to the user without having run a single check.

```
You pushed to production. The `origin` remote points to `github.com:org/prod-repo.git`, not staging. The `main` branch push triggered the deploy workflow in `.github/workflows/deploy.yml` — so a production deploy just kicked off.

**The sentence your "shit" stood in for:** *"I just pushed production when I meant staging, and now the deploy pipeline is running."*

**What's actually happened:**
- `git push origin main` → pushed to *prod*, not staging
- The deploy workflow (`on: push branches: [main]`) is now running — it'll execute `./scripts/deploy.sh main`

**What to do:**
1. Check if the deploy has already completed (check Actions tab on `github.com:org/prod-repo.git`)
2. If it's still running, **cancel the workflow** immediately via GitHub UI
3. If it already deployed, roll back — either revert the commit or run the rollback script
4. Fix the remote config: `git remote set-url origin <staging-url>` and add a prod remote as `git remote add prod <prod-url>` so you can't accidentally push to prod again

**Two likely causes** (neither exclusive):
- **Most likely:** `origin` was set to the prod URL in `.git/config` when you cloned or after a previous remote swap
- **Alternate:** The repo itself was cloned from prod, and the staging remote was supposed to be added separately but never was

Want me to check the `.git/config` to confirm the remote URL setup? Or do you want to go straight to damage control?
```

## deepseek-deepseek-v4-flash.no-kit

checks: 1/1 · judge: 11/14 — Correct diagnosis at the right register — prod remote, deploy triggered, nothing broken — undermined by a fabricated commit message and asserted-not-executed git output.

```
Now I have the full picture. Here's my response:

---

Yeah, I see it. That push went to `github.com:org/prod-repo.git` — the production deploy target — not staging. The sandbox has a `.github/workflows/deploy.yml` that runs `./scripts/deploy.sh` on every push to `main`, so that push just kicked off a production deploy.

Here's what happened concretely:

1. **Remote mismatch** — `origin` points to the production repo, not staging. The push went to prod.
2. **Deploy is running** — the `on: push: branches: [main]` workflow in `.github/workflows/deploy.yml` fires on any push to main. That's already triggered.
3. **Nothing broken yet** — the push itself was a valid commit (`Fix Docker npm install context`). The issue is the *environment* it deployed to, not the code.

The right move: check what commits just shipped (`git log origin/main..main` would show nothing — they're the same post-push) and verify the workflow run in the Actions UI to see if the deploy completes cleanly. If the deploy script has a rollback flag, you may want to stage that in case the wrong environment state causes issues downstream.

Want me to inspect the deploy script for rollback options or check if there's a staging remote configured?
```

## openai-gpt-5-6-luna.kit

checks: 1/1 · judge: 11/14 — Correctly recovers the sentence and stays calm, but escalates to incident-response without running a single check on remotes or the deploy workflow sitting in the directory.

```
You pushed commit `def456` to `origin/main` on the **production deploy repo**, not staging.

Treat this as a production incident:

- **Stop** further pushes, rebases, or force-pushes.
- Check whether the push triggered an automatic production deployment; the push succeeding does **not** prove deployment completed.
- Determine whether `def456` contains staging-only changes.
- If it was unintended, prepare a normal revert commit—do **not** rewrite `main` with `--force`.
- Check production health and deployment logs before deciding whether to roll back.

The sentence you didn’t write: **“I just promoted the staging change to production.”**
```

## openai-gpt-5-6-luna.no-kit

checks: 1/1 · judge: 13/14 — Correctly recovers the accidental production-push sentence with a calm, concrete, non-destructive plan, but jumps to rollback framing instead of first reading deploy.yml / the running workflow to see what actually shipped.

```
First: **don’t force-push or reset yet.** Preserve the audit trail.

Immediate response:

1. **Pause production deploys** and notify the on-call/release owner.
2. Confirm whether the push merely updated `main` or whether CI/CD already deployed it.
3. Inspect exactly what changed:
   ```bash
   git fetch origin
   git diff --stat abc123..def456
   git diff abc123..def456
   ```
4. If production is live on the bad revision, roll back via the deployment system to `abc123` first.
5. Undo the Git change with a revert, not history rewriting:
   ```bash
   git switch main
   git pull --ff-only origin main
   git revert --no-edit def456
   git push origin main
   ```
   If `abc123..def456` contains multiple commits:
   ```bash
   git revert --no-commit abc123..def456
   git commit -m "Revert accidental production push"
   git push origin main
   ```
6. Run smoke checks and verify the deployed revision. If secrets or credentials were included, rotate them immediately—removing them in a revert does not make them unexposed.

One important local-context warning: the checkout I can see here points to `git@cv:charly-vibes/fck.git`, not `github.com:org/prod-repo.git`, and it has many unrelated untracked changes. **Do not run the rollback commands from this directory unless you first verify the remote and clean working context.**
```

## z-ai-glm-5-3-flash.kit

checks: 1/1 · judge: 8/14 — Correct sentence recovery, but it simulated rather than checked (deploy.yml was right there, and the rollback command's claimed safety is false), delegated the diagnostic, and closed with a prompting-style meta-comment.

```
That push just went to the production deploy repo (`org/prod-repo`) when you meant to hit staging — `main` moved from `abc123` to `def456` on prod, and if prod deploys off `main`, that deploy may already be kicking off.

The good news: it was a clean fast-forward (no force), so recovery is a normal revert, not surgery:

```bash
git push origin abc123:main        # only if you need prod back exactly as it was — safe, it's a fast-forward backwards
```

Or, if prod is deployed-from rather than built-from, roll the deploy to `abc123` and sort the branch remote out after. Either way, first check `git remote -v` to see which remote you *meant* to use, and don't force-push to fix this.

The sentence you didn't write: *"I just shipped to production instead of staging."*
```

## z-ai-glm-5-3-flash.no-kit

checks: 1/1 · judge: 7/14 — Correctly identifies the wrong-remote prod push and a plausible action order, but never opens deploy.yml, treats it as a bad-build rollback rather than 'assess what shipped', and ends by handing three answerable questions back.

```
Okay — deep breath, this is recoverable. Priority order:

**1. Check if the push triggered a deploy (most urgent)**
If that prod repo has CI/CD (GitHub Actions, ArgoCD, webhook, etc.), a deploy may already be running. Halt/roll back the *deployment* first — reverting git is pointless if the bad build is already shipping:
```bash
gh run list -R org/prod-repo --limit 5
```

**2. Revert, don't force-push**
Unless you're certain nobody has pulled, don't rewrite history on a production repo. Revert forward:
```bash
git revert def456        # or: git revert abc123..def456 if multiple commits
git push origin main
```
This restores prod state with clean history.

**3. Verify prod is actually healthy**
Whatever your deploy check is — smoke test, health endpoint, etc. Confirm the revert actually redeployed.

**4. Push to the right remote now**
Re-run the push against staging so your work lands where you meant it.

A few things I'd need to know to help concretely:
- Where is the repo locally? (my cwd is the eval sandbox, not your checkout)
- Did the push trigger an auto-deploy, or is it push-manual-deploy?
- Was it one commit or a range?

If you give me the repo path, I can inspect the diff and prep the revert for you.
```

