package routes

import "github.com/gin-gonic/gin"

var (
	router = gin.Default()
)

func Run() {
	getRoutes()
	router.Run(":5001")
}
func getRoutes() {
	metro := router.Group("/stc")
	addMetterRoute(metro)
}
