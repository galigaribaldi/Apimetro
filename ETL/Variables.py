class Developer:
    DEBUG = True
    PORT = '8080'
    DATABASE_URL = 'postgresql://postgres:postgress@localhost:5433/Data'
    DB_USER = ''
    DB_PASSWORD = ''
    SECRET = ''
    HOST = 'http://localhost:' + PORT

class Production:
    DEBUG = False
    PORT = 8080
    DATABASE_URL = 'postgresql://postgres:postgress@localhost:5433/Data'
    DB_USER = ''
    DB_PASSWORD = ''
    SECRET = ''
    HOST = 'https://apimetro.fly.dev'