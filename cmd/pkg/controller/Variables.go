package controller

type Config struct {
	DEBUG        bool
	PORT         int
	DATABASE_URL string
	DB_HOST      string
	DB_USER      string
	DB_PASSWORD  string
	SECRET       string
}
