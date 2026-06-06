package routes

import (
	"embed"
	"io/fs"
	"log"
	"net/http"
	"time"

	MiddlewareMod "Apimetro/cmd/pkg/controller/middleware"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

//go:embed static
var staticFiles embed.FS

var (
	router = gin.Default()
)

// Run inicia la API y configura las rutas para ella.
// La API se configura con las rutas para la API de mapas y la ruta base.
// Luego se inicia el servidor en el puerto 8080 y se configura la ruta para obtener la documentación de la API.
func Run() {
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: false,
		MaxAge:           12 * time.Hour,
	}))

	getRoutes()
	router.GET("/", getInit)
	router.GET("/docs", getDocs)
	subFS, _ := fs.Sub(staticFiles, "static")
	router.StaticFS("/static", http.FS(subFS))
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
	// Analítico (plutarco) — sin ValidarSistema
	analitico := api.Group("/analitico")
	addGeoJsonRouteAgebs(analitico) // #36

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

// getInit sirve la landing page de bienvenida de la API.
func getInit(c *gin.Context) {
	log.Println("APImetro (Servidor de Movilidad CDMX) Vivo!")
	data, _ := staticFiles.ReadFile("static/index.html")
	c.Data(http.StatusOK, "text/html; charset=utf-8", data)
}

// getDocs sirve la página de referencia completa de la API.
func getDocs(c *gin.Context) {
	data, _ := staticFiles.ReadFile("static/docs.html")
	c.Data(http.StatusOK, "text/html; charset=utf-8", data)
}
