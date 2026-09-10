The evidence contradicts the diagnosis:

- `config.yaml` has `timeout: 30`.
- The gateway reports `upstream timeout after 30000ms` — exactly **30 seconds**, not 30 milliseconds.
- If it were misreading `30` as milliseconds, the error should occur around `30ms` and likely report `30ms`.

So the immediate sentence is: **the request is timing out at the configured 30-second value; either the gateway is already converting seconds to milliseconds correctly, or another timeout/configuration is responsible.** Check the parsed config and the effective timeout source before changing the unit.
