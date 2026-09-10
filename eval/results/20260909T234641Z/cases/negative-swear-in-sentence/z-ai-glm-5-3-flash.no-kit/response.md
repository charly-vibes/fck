Fixed. Summary:

- **Cause:** `SELECT * FORM users` in `server.js` — a typo (`FORM` → `FROM`) that makes every `/users` query throw a SQL syntax error, which surfaces as a 500.
- **Fix:** corrected the query in `server.js` (line 2).

Two caveats:

1. **Nothing is listening on port 3000 from this sandbox**, so I couldn't reproduce or verify the fix live — your health check must have been running the server elsewhere. Restart it and `/api/users` should return 200 with your rows.
2. Worth noting the route has no error handling — any future DB failure will 500 with no log trail. If you want, I can wrap it in a try/catch or add an async error wrapper so failures at least get logged.
