import os
from pathlib import Path

def load_env(path=".env"):
    p = Path(path)
    if not p.exists():
        return
    for line in p.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        os.environ.setdefault(key.strip(), value.strip())

load_env()

def get_db_url():
    return os.environ["DATABASE_URL"]

if __name__ == "__main__":
    print(get_db_url())
