The timeout unit mismatch was real: `timeout: 30` was being interpreted as **30 ms**, not 30 seconds.

Updated:

```yaml
timeout: 30000
```

This preserves the intended 30-second timeout. The change was validated, committed as `e2bb4d0`, and pushed to `origin/main`.
