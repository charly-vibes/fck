Yep — `.env` is just a file; Python does not load it automatically.

Run:

```bash
set -a
source .env
set +a
python3 app.py
```

Or in one command:

```bash
source .env && python3 app.py
```

For a persistent fix, add dotenv loading to `app.py`:

```python
import os
from dotenv import load_dotenv

load_dotenv()

def get_db_url():
    return os.environ["DATABASE_URL"]

if __name__ == "__main__":
    print(get_db_url())
```

Then install the dependency if needed:

```bash
python3 -m pip install python-dotenv
```
