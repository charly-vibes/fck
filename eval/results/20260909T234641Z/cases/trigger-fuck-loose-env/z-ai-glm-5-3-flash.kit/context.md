Last command and its output:

python3 app.py
Traceback (most recent call last):
  File "app.py", line 8, in <module>
    print(get_db_url())
  File "app.py", line 2, in get_db_url
    return os.environ["DATABASE_URL"]
KeyError: 'DATABASE_URL'
(the shell had not sourced .env this time — previous runs used `source .env && python3 app.py`)
