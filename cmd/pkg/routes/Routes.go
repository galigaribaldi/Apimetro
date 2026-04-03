package routes

import (
	"log"

	MiddlewareMod "Apimetro/cmd/pkg/controller/middleware"
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
	// Subgrupos para mapas
	mapas := api.Group("/mapas")
	addGeoJsonRouteEstacion(mapas)
	addGeoJsonRouteLine(mapas)
	addGeoJsonRoutePoligono(mapas)
	// Arquitectura dinámica dependiendo del sistema de transporte
	transporte := api.Group("/:sistema")
	transporte.Use(MiddlewareMod.ValidarSistema())
	{
		addLineRoute(transporte)
		addEstacionRoute(transporte)
		addDescriptionLineRoute(transporte)
		addDescripcionEstacionRoute(transporte)
	}
}

func getInit(c *gin.Context) {
	log.Println("APImetro (Servidor de Movilidad CDMX) Vivo!")
	c.JSON(http.StatusOK,
		gin.H{"status": "alive!"})
}
