Hold on — your own error message contradicts the diagnosis. Here's what the evidence actually says:

**1. The unit parsing is fine.** `{"error":"upstream timeout after 30000ms"}` = 30 **seconds**. That's `timeout: 30` correctly read as seconds. If the gateway had parsed it as milliseconds, the request would have died in ~30ms and the message would say `after 30ms`. Nothing is dying "near-instantly" — it hangs for the full 30s budget and then times out.

**2. The real symptom is: the upstream is hanging, not the config.** The gateway waited its entire 30-second window and got nothing. Suspects:

- **Self-loop** — your `config.yaml` has `endpoint: http://localhost:8080/api`. If the gateway *itself* listens on `:8080`, it's routing to itself → each hop re-enters the gateway until the timeout fires. Classic config bug. Check whether gateway listen-port == upstream port.
- Upstream service is hung/slow (DB stuck, dead connection, no read timeout on the socket).

**3. I can't reproduce or inspect any of it here.** This sandbox contains only `config.yaml` — no gateway source, and nothing is even listening on 8080 from here:

```
curl: (7) Failed to connect to localhost:8080 after 0 ms
```

So there's no code to confirm a millisecond bug against anyway.

**Next steps:**
1. `ss -tlnp | grep 8080` on the machine where the gateway runs — identify what's on that port.
2. If the gateway's own bind port is 8080 → fix `endpoint` in config.yaml to the real upstream.
3. Hit the upstream directly (`curl http://<real-upstream>/...`) — if *that* hangs, the problem is upstream, not the gateway's timeout units.

If you can drop the gateway's source (or tell me where it lives), I can verify the parsing logic directly instead of inferring from the error string.
