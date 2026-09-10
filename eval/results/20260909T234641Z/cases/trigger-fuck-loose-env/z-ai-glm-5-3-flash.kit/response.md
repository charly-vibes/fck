The sentence: the traceback is exactly what it looks like — `app.py` reads `os.environ["DATABASE_URL"]` directly, and this shell never got the variable because nothing loaded `.env`. Nothing's broken; the run just skipped the `source .env &&` prefix this time.

Two ways to stop tripping over it:

```bash
# per-run, current shell
set -a; source .env; set +a; python3 app.py
```

Or make it permanent in `app.py` so plain `python3 app.py` works anywhere:

```python
import os
from pathlib import Path
from dotenv import load_dotenv   # pip install python-dotenv

load_dotenv(Path(__file__).parent / ".env")
```

Say the word and I'll add the loader line to `app.py`.
