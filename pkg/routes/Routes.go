package routes

import (
	"log"

	"net/http"

	"github.com/gin-gonic/gin"
)

var (
	router = gin.Default()
)

func Run() {
	getRoutes()
	router.GET("/", getInit)
	router.Run(":8080")

}
func getRoutes() {
	metro := router.Group("/stc")
	addMetterRoute(metro)
}

func getInit(c *gin.Context) {
	log.Println("Alive")
	c.JSON(http.StatusOK, 200)
	return
}
