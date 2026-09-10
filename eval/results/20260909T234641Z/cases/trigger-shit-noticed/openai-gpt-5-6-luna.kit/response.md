You pushed commit `def456` to `origin/main` on the **production deploy repo**, not staging.

Treat this as a production incident:

- **Stop** further pushes, rebases, or force-pushes.
- Check whether the push triggered an automatic production deployment; the push succeeding does **not** prove deployment completed.
- Determine whether `def456` contains staging-only changes.
- If it was unintended, prepare a normal revert commit—do **not** rewrite `main` with `--force`.
- Check production health and deployment logs before deciding whether to roll back.

The sentence you didn’t write: **“I just promoted the staging change to production.”**
