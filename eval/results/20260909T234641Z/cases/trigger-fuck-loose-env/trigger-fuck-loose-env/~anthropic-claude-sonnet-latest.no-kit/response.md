Fixed. The `.env` file wasn't sourced in this shell session, so `DATABASE_URL` was unset. Running `source .env && python3 app.py` (or `source .env && export DATABASE_URL && python3 app.py`) works correctly and prints:

```
postgres://localhost:5432/app
```

For future runs, remember to `source .env` first, or better — load it automatically in `app.py` with something like `python-dotenv`:

```python
from dotenv import load_dotenv
load_dotenv()
```
