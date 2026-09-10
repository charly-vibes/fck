`DROP TABLE` is PostgreSQL’s success output. The migration executed a table drop against whatever database `$PROD_URL` resolved to.

Stop running migrations or cleanup commands now. Do not rerun it.

Possible states:

- **Intended drop:** expected migration, no incident.
- **Accidental drop:** table and its data may be gone; `CASCADE` may also have removed dependent objects.
- **Wrong target:** `$PROD_URL` may not point to the database you thought it did.
- **Partial migration:** `psql` can continue after an earlier error unless `ON_ERROR_STOP` was enabled.

Treat this as a production data-loss incident until verified. Preserve the terminal output and check—read-only—the exact `DROP TABLE` statement in `migrate.sql`, the resolved database identity, and whether the table still exists. If it was unintended, use the database backup/PITR path; don’t attempt ad-hoc recreation before checking recovery options.
