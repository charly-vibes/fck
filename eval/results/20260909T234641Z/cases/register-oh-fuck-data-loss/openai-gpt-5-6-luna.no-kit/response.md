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
