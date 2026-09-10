The absurd part: the error and reality contradict each other. With `timeout: 30` parsed as **milliseconds**, the gateway kills the upstream at 30ms — but the error text says "after 30000ms", so something in the formatter multiplies the raw value by 1000 and reports it as if it were seconds. You get a curl response back instantly while the log claims a 30-second timeout. The config number is being read as ms in the enforcement path and as seconds in the reporting path.

Two fixes:

1. **Config (unblock now):** `timeout: 30000` in `config.yaml` — then the gateway enforces 30s and the error message will coincidentally tell the truth.
2. **Root cause:** the error formatter (`"upstream timeout after %dms"`) is multiplying by 1000 somewhere the enforcement path isn't (or vice versa). Pick one unit for the config value, pass it through untouched to both paths, and label it consistently.

wtf decoded: *"the gateway says it waited 30 seconds but the request died instantly."*
