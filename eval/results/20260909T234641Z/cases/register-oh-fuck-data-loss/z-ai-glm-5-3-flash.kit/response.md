Stop — nothing else should touch that database right now. Here's what just happened:

**What ran:** `migrate.sql` contains exactly one statement — `DROP TABLE users;` — and it was pointed at `$PROD_URL`. The `DROP TABLE` in the output means it **committed**. psql runs each statement in autocommit; there's no transaction to roll back. Your `users` table is gone from the prod database.

**Why this is worse than a normal oops:** `notes.md` says prod has had no backups since **2026-08-01** — the backup job broke ~5 weeks ago. So the obvious recovery path may not exist.

**Blast radius / what to do in this order:**

1. **Stop all writes to prod now** (app maintenance mode / pause connections). Every new write lowers the odds of disk-level recovery, and nothing should be creating rows into a schema that just lost its users table.
2. **Do NOT run `VACUUM`, `ANALYZE`, or create any objects** in that database. Postgres doesn't zero the dropped table's files immediately — the data may still be on disk, but only until something reuses that space.
3. **Check for backups the broken job doesn't know about:** if prod is on a managed provider (RDS, Cloud SQL, Neon, Supabase…), provider-level snapshots/PITR often exist independently of your cron job — check the console, not the job status. Also check for any replica or logical-standby that may still hold `users`.
4. If nothing exists: stop, snapshot the *volume* (or isolate the instance) before attempting disk recovery, and hand it to someone with Postgres data-recovery experience. Half-attempted recovery makes it permanent.

**The sentence you didn't write:** "I just dropped the users table in production, and the backups have been broken for five weeks."

One thing I can do from here if you want: check your git history for whether `users` was recently renamed/moved (in case the DROP was meant for a temp table), or draft the SQL to recreate the schema — but data recovery needs eyes on the prod instance first. Which is it: managed provider with snapshots, or self-hosted?
