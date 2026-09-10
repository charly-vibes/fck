Found it — the 500s come from a SQL typo in `server.js` line 2:

```sql
SELECT * FORM users   -- FORM → FROM
```

Postgres rejects the statement with a syntax error, the async handler rejects, and Express turns that into a 500 on `/users`. `/api/health` is fine because it never touches the DB.

Fixed (`server.js:2` now reads `SELECT * FROM users`). I couldn't reproduce the 500 live — nothing is running on port 3000 in this sandbox — so restart your server and hit `/users` again to confirm it returns 200.
