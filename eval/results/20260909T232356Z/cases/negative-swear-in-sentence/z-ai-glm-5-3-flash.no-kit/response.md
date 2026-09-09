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
