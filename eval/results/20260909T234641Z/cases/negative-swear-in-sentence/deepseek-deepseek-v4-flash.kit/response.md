The sandbox's `server.js` only has the route snippet — the actual `./db` module lives in the project root, so the server can't restart from here. But the root cause is clear:

**Typo in `/users` handler:** `SELECT * FORM users` → `SELECT * FROM users`

The file is fixed. To apply it, the server needs restarting from the project root where `./db` exists:

```bash
# From the project root directory (where db.js lives):
node -e "
  const express = require('express');
  const db = require('./db');
  global.app = express();
  global.db = db;
  require('./server');
  app.listen(3000, () => console.log('listening'));
"
```

Fix summary: One character — `FORM` → `FROM` — was the sole cause of the 500s on `/users`.
