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
