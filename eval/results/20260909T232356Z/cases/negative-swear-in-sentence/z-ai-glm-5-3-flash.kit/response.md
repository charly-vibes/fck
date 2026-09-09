Fixed. Summary:

- **Cause:** `SELECT * FORM users` — a typo (`FORM` → `FROM`). Every call to `/users` threw a SQL syntax error.
- **Why it showed as a 500:** the handler is `async` and there's no try/catch, so the rejected promise never got handled and Express returned a 500.
- **Why `/api/health` was fine:** it doesn't query the DB.

The file is patched in `server.js`. One recommendation: add an error wrapper around async routes (or a catch-all error middleware) so a bad query returns a real error message instead of a bare 500 — happy to add that if you want. Note the server wasn't running when I checked (nothing on port 3000), so restart it and hit `/users` to confirm.
