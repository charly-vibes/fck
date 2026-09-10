That push just went to the production deploy repo (`org/prod-repo`) when you meant to hit staging — `main` moved from `abc123` to `def456` on prod, and if prod deploys off `main`, that deploy may already be kicking off.

The good news: it was a clean fast-forward (no force), so recovery is a normal revert, not surgery:

```bash
git push origin abc123:main        # only if you need prod back exactly as it was — safe, it's a fast-forward backwards
```

Or, if prod is deployed-from rather than built-from, roll the deploy to `abc123` and sort the branch remote out after. Either way, first check `git remote -v` to see which remote you *meant* to use, and don't force-push to fix this.

The sentence you didn't write: *"I just shipped to production instead of staging."*
