Last command and its output:

curl http://localhost:8080/api
{"error":"upstream timeout after 30000ms"}

(config.yaml says timeout: 30 — but the gateway parses it as milliseconds while the client means seconds, so requests die near-instantly)
