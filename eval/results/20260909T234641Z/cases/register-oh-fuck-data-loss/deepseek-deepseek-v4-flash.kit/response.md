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
