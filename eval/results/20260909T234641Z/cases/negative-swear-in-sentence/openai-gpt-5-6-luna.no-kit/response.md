Found the cause in `server.js`:

```js
SELECT * FORM users
```

`FORM` was a SQL typo; it’s now corrected to:

```js
SELECT * FROM users
```

`node --check` and `git diff --check` pass. The fix was committed and pushed as `2ef33e4`.

I couldn’t re-test `/users` because `localhost:3000` wasn’t listening in this shell, so restart the API if it doesn’t hot-reload.
