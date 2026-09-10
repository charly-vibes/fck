Fixed. `python3 app.py` now works with or without sourcing `.env`:

**What changed in `app.py`:** added a tiny `load_env()` helper that parses `.env` (skipping blanks/comments) and uses `os.environ.setdefault` — so explicitly set env vars still take precedence over the file. No dependencies, runs on import.
