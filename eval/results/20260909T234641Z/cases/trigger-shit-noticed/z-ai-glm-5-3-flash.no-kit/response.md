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
