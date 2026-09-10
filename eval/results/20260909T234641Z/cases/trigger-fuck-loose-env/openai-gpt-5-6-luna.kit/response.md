`app.py` is fine; this run simply lacked `DATABASE_URL` in its environment.

Run:

```bash
source .env && python3 app.py
```

For a shell-independent fix, load `.env` in the application with `python-dotenv`:

```python
from dotenv import load_dotenv
load_dotenv()
```

Then install it if needed:

```bash
pip install python-dotenv
```
