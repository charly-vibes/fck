That line missing? `source .env &&` — you know it. `.env` is right there, app.py reads `os.environ["DATABASE_URL"]`, and bare `python3 app.py` doesn't load dotfiles. Same run as before, minus the source, same KeyError.

The missing sentence: **`source .env && python3 app.py`**
