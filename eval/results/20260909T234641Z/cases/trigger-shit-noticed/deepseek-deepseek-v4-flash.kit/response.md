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
