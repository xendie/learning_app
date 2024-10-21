import mysql.connector
from dotenv import load_dotenv
import os
from pathlib import Path

if os.getenv('ENVIRONMENT') != 'production':
    env_path = Path(__file__).resolve().parent.parent / '.env'
    load_dotenv(dotenv_path=env_path)

def get_sql_connection():
    return mysql.connector.connect(
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        host=os.getenv('DB_HOST'),
        database=os.getenv('DB_NAME')
    )