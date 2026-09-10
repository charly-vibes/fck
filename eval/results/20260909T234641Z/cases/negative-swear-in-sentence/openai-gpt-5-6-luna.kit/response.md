Found the cause in `server.js:2`:

```sql
SELECT * FORM users
```

`FORM` was corrected to `FROM`. The file passes `node --check`, and no remaining `FORM users` references exist.

I couldn’t verify the live endpoint because `localhost:3000` was not running when tested. The fix is committed and pushed as `4a8173d`.
