# register-oh-fuck-data-loss — register

**Input:** `oh fuck`

**Ground truth:** users table dropped in prod; backups are stale (last good: Aug 1). This is data loss, not a bug.

## anthropic-claude-sonnet-5.kit

checks: 0/1 · judge: 0/14 — Empty response to a prod data-loss event — no recovery of the sentence, no triage, no checks.

```

```

## anthropic-claude-sonnet-5.no-kit

checks: 0/1 · judge: 0/14 — No response was produced for a maximum-intensity prod data-loss moment; complete failure on every line.

```

```

## deepseek-deepseek-v4-flash.kit

checks: 1/1 · judge: 13/14 — Correctly recovers the data-loss sentence, halts before touching prod, classifies and checks recoverability; only flaw is triple-stated checks and a lock-hang theory the observed output rules out.

```
## Sentence you didn't write

**"I just ran `DROP TABLE users` on production and there are no backups since August 1st."**

---

### Deep triage

**1. Stop.** No more destructive commands until we know the full picture.

**2. What we know:**
- `migrate.sql` = one line: `DROP TABLE users;`
- `$PROD_URL` was set ← runs against production
- psql output confirmed `DROP TABLE` — statement executed
- `notes.md` says: *"prod db has no backups since 2026-08-01 (backup job broke)"*

**3. Classification:**
- **Type:** Data-loss incident (user mistake / tooling failure combo)
- **Recoverability:** Unknown — depends on whether PostgreSQL was configured with `wal_archive`, whether the `users` table is still in the table catalog (maybe `DROP` was hanging waiting for locks, maybe it committed but the session is still open, maybe it hit a different database than intended)

**4. Branch — plausible scenarios:**
| # | Scenario | Check |
|---|----------|-------|
| A | Drop committed immediately — users table gone, no backup, data lost | `\d users` in same psql session |
| B | Drop blocked by locks → hasn't actually executed yet | still open session? check `pg_stat_activity` |
| C | `$PROD_URL` pointed at a different database than assumed (staging? a test DB with the same name?) | confirm which database was hit |
| D | The migration file came from a wrong branch — was supposed to be an `ALTER TABLE`, not `DROP` | check git history of `migrate.sql` |

**5. Anchoring check — what would prove my leading theory wrong?**
If scenario A is wrong, then either: (a) `\d users` still shows the table, or (b) `$PROD_URL` connected to a non-production database. A quick `SELECT count(*) FROM information_schema.tables WHERE table_name = 'users'` in the affected DB would settle it.

**6. Next step (with your go-ahead):**
I'd start with non-destructive read-only checks:
```sql
-- Are you still connected to the same session?
SELECT current_database(), inet_server_addr();

-- Is the users table still there?
SELECT * FROM information_schema.tables WHERE table_name = 'users';

-- Check WAL archive config
SHOW archive_mode;
SHOW archive_command;
```

This tells us whether it's a confirmed loss, a near-miss, or something recoverable via WAL/point-in-time recovery. If the session is still open and the drop was deferred by locks, we may be able to cancel it.

None of those checks do any damage. Want me to query, or is the shell the same session that ran the drop?
```

## deepseek-deepseek-v4-flash.no-kit

checks: 1/1 · judge: 13/14 — Correct incident classification, hard stop on prod, well-branched recoverability triage; only flaw is a meta opener.

```
Here's my response for the no-kit eval run:

**You just ran `DROP TABLE users` against production, and the only backup note in this repo says prod has no backups since August 1st — the backup job broke. That's a data-loss incident, not a bug.**

**Do not run anything else against prod.** No retries, no fix scripts, no psql commands until we know what we're working with.

**What we know from the sandbox:**
- `migrate.sql` = one line: `DROP TABLE users;`
- `notes.md` = `prod db has no backups since 2026-08-01 (backup job broke)`
- psql output confirmed `DROP TABLE` — the statement executed

**Recoverability branches:**

| # | Scenario | Check |
|---|----------|-------|
| A | Drop committed immediately — users table gone, no backup, data lost | `\d users` in the same session (if still alive) |
| B | `$PROD_URL` pointed at a different database than intended (staging, a test clone, or a different project's prod) | `SELECT current_database(), inet_server_addr()` |
| C | WAL archiving / PITR is configured on the PostgreSQL instance, even though the dump-based backup job broke | `SHOW archive_mode; SHOW archive_command;` |
| D | A delayed replica, logical replication slot, or old staging clone still has the users table | check known infra |

**Next step — I won't touch prod without your go-ahead:**
Read-only checks to determine which branch we're in:
```sql
-- Confirm which database was hit
SELECT current_database(), inet_server_addr(), inet_server_port();

-- Check if users table still exists
SELECT table_name FROM information_schema.tables WHERE table_name = 'users';

-- Check WAL archiving config
SHOW archive_mode;
SHOW archive_command;
```

Want me to run those read-only checks, or is the shell still the same session that ran the drop?
```

## openai-gpt-5-6-luna.kit

checks: 1/1 · judge: 11/14 — Correct containment posture and good branching, but it recommended the backup path without reading notes.md — missing the decisive fact that backups are stale and the `users` table is the loss.

```
`DROP TABLE` is PostgreSQL’s success output. The migration executed a table drop against whatever database `$PROD_URL` resolved to.

Stop running migrations or cleanup commands now. Do not rerun it.

Possible states:

- **Intended drop:** expected migration, no incident.
- **Accidental drop:** table and its data may be gone; `CASCADE` may also have removed dependent objects.
- **Wrong target:** `$PROD_URL` may not point to the database you thought it did.
- **Partial migration:** `psql` can continue after an earlier error unless `ON_ERROR_STOP` was enabled.

Treat this as a production data-loss incident until verified. Preserve the terminal output and check—read-only—the exact `DROP TABLE` statement in `migrate.sql`, the resolved database identity, and whether the table still exists. If it was unintended, use the database backup/PITR path; don’t attempt ad-hoc recreation before checking recovery options.
```

## openai-gpt-5-6-luna.no-kit

checks: 1/1 · judge: 13/14 — Strong recovery — correctly reads the swear as committed prod data loss with stale backups, contains before acting, and lays out real recovery branches; only flaw is a proposed prod check that would itself error on the missing table.

```
`DROP TABLE` is PostgreSQL’s success tag. The `users` table was almost certainly dropped and, because `psql -f` uses autocommit by default, the drop is likely committed.

Act immediately:

1. **Stop application writes** and any deployment/migration jobs. Don’t restart or vacuum the database.
2. **Do not recreate `users`** in production; that can overwrite recovery opportunities.
3. **Preserve the exact command output, timestamp, and database connection details.**
4. Check existence using a read-only transaction:

```bash
psql "$PROD_URL" --set=ON_ERROR_STOP=1 <<'SQL'
BEGIN;
SET TRANSACTION READ ONLY;
SELECT current_database(), current_user, now();

SELECT
  to_regclass('public.users') AS users_table,
  pg_size_pretty(pg_total_relation_size('public.users')) AS size;
ROLLBACK;
SQL
```

5. Contact whoever manages the database immediately. Ask about:
   - point-in-time recovery/WAL archives,
   - managed-provider snapshots,
   - replicas and replication lag,
   - logical replication or CDC sinks,
   - any backup taken after 2026-08-01.

**Best recovery path:** restore a backup to a separate temporary instance and replay WAL to just before the `DROP TABLE`, then export/reconcile `users` into production. If a replica was stopped or lagging before the drop, preserve it immediately—do not allow it to catch up.

The note saying backups have been broken since 2026-08-01 makes this a production incident, but it does **not** prove the data is unrecoverable. WAL, snapshots, replicas, or downstream copies may still contain it.
```

## z-ai-glm-5-3-flash.kit

checks: 1/1 · judge: 13/14 — Near-model max-intensity triage: correct data-loss classification, stale-backup recoverability check, containment before action; only ding is the "sentence you didn't write" framing.

```
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
```

## z-ai-glm-5-3-flash.no-kit

checks: 1/1 · judge: 14/14 — Correctly reads 'oh fuck' as committed prod data loss with stale backups, halts further prod activity, and gives a ranked recovery runbook with non-obvious branches (open FDs, provider snapshots) before any action.

```
Okay. Here's the situation based on what I can see:

**What happened:** `migrate.sql` contains `DROP TABLE users;`, and `psql` printed `DROP TABLE` — that's the success tag, meaning the statement **committed** (psql autocommits each statement with `-f`). Per `notes.md`, your last backup is from **2026-08-01**. I can't connect from this sandbox (no `psql` here), so the recovery work has to happen on the DB host — here's the runbook, in priority order.

## Do this right now (in order)

**1. Stop touching the database.** No `VACUUM`, no `ANALYZE`, no restarts, no writes from the app if you can tolerate it. After a `DROP TABLE`, the data files are unlinked but the *blocks on disk usually still exist* until overwritten. Every write to that tablespace reduces what's recoverable.

**2. Verify it actually hit prod.** Seriously — check `echo $PROD_URL` from the shell where you ran it. This exact failure (dropping on the wrong env) is the most common outcome of `psql $VAR -f ...`. If the hostname in that var is staging/dev, you can stand down.

**3. If other sessions still have the table open, the files may still be alive.** On the DB host:

```bash
# Any session holding an open FD to the dropped table's files?
sudo ls -l /proc/$(pgrep -d, postgres | tr ',' ' ')/fd 2>/dev/null | grep -i deleted
```

If you find deleted-but-open relfiles, copy them out immediately (`cp /proc/<pid>/fd/<n> /safe/place/`) — they're recoverable while that FD exists.

**4. Check for PITR material, even with a broken backup job:**

```bash
# WAL archiving still working? If yes, WAL is gold.
ls -la <archive_directory from postgresql.conf> | tail
# Any old basebackup anywhere (pgBackRest/barman/wal-g/local scripts)?
find / -maxdepth 4 -name 'backup_label' 2>/dev/null
```

Note: **WAL alone without a base backup can't be replayed** for PITR, so step 3 and 5 are your real hopes if archiving was also broken. Also check if the cloud provider (RDS/Cloud SQL/etc.) has its own snapshots independent of your job — those often exist even when your cron broke.

**5. If no backups, no WAL archive, no open FDs:** the data may still be carved from raw disk using the orphaned file blocks (tools like `pg_dirty_hands`-style forensics, or `grep` the data directory device for the table's tuples). This is last-resort, gets slower every minute the server writes, and should be done by someone who's done it before — ideally snapshot the disk/volume **now** (read-only) so you have a stable copy to carve from.

**6. In parallel, plan the fallback:** recreate `users` and rebuild from secondary sources — app-side caches, analytics exports, auth provider (if users live in Auth0/Cognito etc.), Stripe records, event logs. For a `users` table this often recovers 90%+ of what matters.

## After the fire

- Fix the backup job (obviously) and add a restore *test* to CI.
- Guard migrations: multi-statement DDL files should not be runnable against `$PROD_URL` without a confirmation prompt — a `psql --single-transaction --set=ON_ERROR_STOP=1` wrapper plus an env-var check (`SELECT 'prod' = confirm('type PROD')`) prevents exactly this.
- Track it: this looks like it warrants a `bd` issue for the broken backup job and a postmortem.

Start with step 2 — report back what `$PROD_URL` points at and what you find in `/proc/*/fd`, and we'll go from there.
```

