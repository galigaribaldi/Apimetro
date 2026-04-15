import os

host     = os.getenv('DB_HOST',     'localhost')
database = os.getenv('DB_NAME',     'db_apimetro')
user     = os.getenv('DB_USER',     'prueba')
password = os.getenv('DB_PASSWORD', 'postgres')
port     = os.getenv('DB_PORT',     '5432')
keepalive_kwargs = {
  "keepalives": 1,
  "keepalives_idle": 60,
  "keepalives_interval": 10,
  "keepalives_count": 5
}