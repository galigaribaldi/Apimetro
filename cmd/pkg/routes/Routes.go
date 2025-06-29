package routes

import (
	"log"

	"net/http"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"     // swagger embed files
	ginSwagger "github.com/swaggo/gin-swagger" // gin-swagger middleware
)

var (
	router = gin.Default()
)

func Run() {
	getRoutes()
	router.GET("/", getInit)
	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	router.Run(":8080")

}

func getRoutes() {
	stc := router.Group("/stc")
	addLineRoute(stc)
	addEstacionRoute(stc)
	addDescriptionRoute(stc)
	addGeoJsonRoute(stc)
}

func getInit(c *gin.Context) {
	log.Println("Alive")
	c.JSON(http.StatusOK, 200)
	return
}
