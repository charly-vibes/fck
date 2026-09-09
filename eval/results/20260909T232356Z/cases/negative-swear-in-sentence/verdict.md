# negative-swear-in-sentence — negative

**Input:** `the fucking API keeps returning 500s on /users, can you look at it?`

**Ground truth:** SQL typo: 'SELECT * FORM users' should be 'FROM'.

## z-ai-glm-5-3-flash.kit

checks: 2/2 · judge: 13/14 — Correct, minimal, no decoder theater; only flaw is a port-3000 'not running' claim that conflicts with the visible health-check output.

```
Fixed. Summary:

- **Cause:** `SELECT * FORM users` — a typo (`FORM` → `FROM`). Every call to `/users` threw a SQL syntax error.
- **Why it showed as a 500:** the handler is `async` and there's no try/catch, so the rejected promise never got handled and Express returned a 500.
- **Why `/api/health` was fine:** it doesn't query the DB.

The file is patched in `server.js`. One recommendation: add an error wrapper around async routes (or a catch-all error middleware) so a bad query returns a real error message instead of a bare 500 — happy to add that if you want. Note the server wasn't running when I checked (nothing on port 3000), so restart it and hit `/users` to confirm.
```

## z-ai-glm-5-3-flash.no-kit

checks: 2/2 · judge: 13/14 — Correct, checked, non-deflecting fix; only flaw is a hedge opener and a redundant closing restatement.

```
Fixed ✅ — `server.js` now reads `SELECT * FROM users`.

Two more things worth noting:

1. **No server is currently listening on port 3000 from this sandbox** — even `/api/health` is refusing connections now (it worked in your last command, so the process may have died or is running elsewhere). You'll need to restart it to verify the fix.
2. **Optional hardening** — the handler has no error handling, so any future DB hiccup will also surface as an unhandled rejection/500. Something like this would make failures loggable:

```js
app.get('/users', async (req, res, next) => {
  try {
    const users = await db.query('SELECT * FROM users');
    res.json(users.rows);
  } catch (err) {
    next(err);
  }
});
```

So: the 500s were caused by a typo (`FORM` → `FROM`) in the SQL query. Restart the server and `/users` should come back clean.
```

