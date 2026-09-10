import os
from dotenv import load_dotenv

load_dotenv()

def get_db_url():
    return os.environ["DATABASE_URL"]

if __name__ == "__main__":
    print(get_db_url())
