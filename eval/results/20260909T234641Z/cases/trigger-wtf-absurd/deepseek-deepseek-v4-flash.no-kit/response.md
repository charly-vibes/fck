The absurdity: **Config timeout unit mismatch.** `config.yaml` says `timeout: 30` (a human means 30 seconds), but the gateway parses it as milliseconds (30ms). Requests die near-instantly because the gateway's timeout is `30ms`, not 30 seconds.

**Fix:** change `timeout: 30` to `timeout: 30000` in `config.yaml`, or fix the gateway to interpret the value as seconds.
