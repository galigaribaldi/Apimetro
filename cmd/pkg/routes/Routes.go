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

// Run inicia la API y configura las rutas para ella.
// La API se configura con las rutas para la API de mapas y la ruta base.
// Luego se inicia el servidor en el puerto 8080 y se configura la ruta para obtener la documentación de la API.
func Run() {
	getRoutes()
	router.GET("/", getInit)
	router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	router.Run(":8080")

}

// getRoutes configura las rutas para la API, teniendo en cuenta
// la arquitectura dinámica dependiendo del sistema de transporte
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

// getInit obtiene el estado actual de la API y devuelve un mensaje de prueba.
func getInit(c *gin.Context) {
	log.Println("APImetro (Servidor de Movilidad CDMX) Vivo!")
	c.JSON(http.StatusOK,
		gin.H{"status": "alive!"})
}
