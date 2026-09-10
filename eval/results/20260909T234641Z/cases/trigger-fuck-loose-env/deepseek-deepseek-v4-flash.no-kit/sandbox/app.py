import os
from pathlib import Path

def load_dotenv():
    env_file = Path(".env")
    if not env_file.exists():
        return
    for line in env_file.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        value = value.strip().strip('"').strip("'")
        os.environ.setdefault(key, value)

def get_db_url():
    return os.environ["DATABASE_URL"]

if __name__ == "__main__":
    load_dotenv()
    print(get_db_url())
