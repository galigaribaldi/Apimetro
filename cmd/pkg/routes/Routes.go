package routes

import (
	"log"

	"net/http"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
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
	// Ruta Base
	api := router.Group("/movilidad")

	// Subgrupos divididos por transporte
	metro := api.Group("/metro")
	metrobus := api.Group("/metrobus")
	cablebus := api.Group("/cablebus")
	// Subgrupos para mapas
	mapas := api.Group("/mapas")

	addLineRoute(metro)
	addEstacionRoute(metro)
	addDescriptionRoute(metro)

	addGeoJsonRouteEstacion(mapas)
	addGeoJsonRouteLine(mapas)
	_, _ = metrobus, cablebus

}

func getInit(c *gin.Context) {
	log.Println("APImetro (Servidor de Movilidad CDMX) Vivo!")
	c.JSON(http.StatusOK,
		gin.H{"status": "alive!"})
}
