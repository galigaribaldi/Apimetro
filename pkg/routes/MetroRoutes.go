package routes

import (
	"log"
	"net/http"
	"strconv"
	"strings"

	metro "Apimetro/pkg/controller/metro"
	"Apimetro/pkg/models"

	"github.com/gin-gonic/gin"
)

func addMetterRoute(rg *gin.RouterGroup) {
	//Estaciones
	rg.GET("/estacion", getEstacion)
	rg.POST("/estacion", postEstacion)
	rg.DELETE("/estacion", deleteEstacion)
	//Lineas
	rg.GET("/linea", getLinea)
	rg.POST("/linea", postLinea)
	rg.DELETE("/linea", deleteLinea)
}

// Obtener datos de Estaciones
func getEstacion(c *gin.Context) {
	nombreEstacion := c.Query("nombre")
	anioEstacion := c.Query("anio")
	anioAntes := c.Query("anio_antes")
	anioDespues := c.Query("anio_despues")
	ciudadEstacion := c.Query("ciudad")
	alacaldiaMunicipio := c.Query("alacaldia_municipio")
	colorEstacionEsp := strings.ToUpper(c.Query("color_esp"))
	colorEstacionEn := strings.ToUpper(c.Query("color_en"))
	idLinea, err := strconv.Atoi(c.Query("linea_id"))
	if err != nil && idLinea != 0 {
		c.JSON(http.StatusBadRequest, err)
		return
	}
	//nombre de la Estacion
	if nombreEstacion != "" {
		log.Println("Nombre de la estacion: ", nombreEstacion)
		c.JSON(http.StatusOK, metro.SelectEstacionbyName(nombreEstacion))
		return
	}
	//Año de inauguracion de la linea
	if anioEstacion != "" {
		log.Println("Año de la estacion: ", anioEstacion)
		c.JSON(http.StatusOK, metro.SelectEstacionbyAnio(anioEstacion))
		return
	}
	//Año de inauguracion de la linea (Rango)
	if anioAntes != "" || anioDespues != "" {
		log.Println("Año de la estacion (rangos): ", anioAntes, anioDespues)
		c.JSON(http.StatusOK, metro.SelectEstacionbyAnioRango(anioAntes, anioDespues))
		return
	}
	// Localizacion Estado Ciudad
	if ciudadEstacion != "" {
		log.Println("Estado - Ciudad: ", ciudadEstacion)
		c.JSON(http.StatusOK, metro.SelectEstacionbyCiudad(ciudadEstacion))
		return
	}
	// Localizacion Alcaldia o municipio
	if alacaldiaMunicipio != "" {
		log.Println("Alcaldia o municipio: ", alacaldiaMunicipio)
		c.JSON(http.StatusOK, metro.SelectEstacionbyAlcaldia(alacaldiaMunicipio))
		return
	}
	// Numero de la linea
	if idLinea != 0 {
		log.Println("Linea ID: ", idLinea)
		c.JSON(http.StatusOK, metro.SelectEstacionbyLineaID(idLinea))
		return
	}
	//Color Español - Ingles
	if colorEstacionEsp != "" || colorEstacionEn != "" {
		if colorEstacionEsp != "" {
			log.Println("Color español: ", colorEstacionEsp)
			var idioma = "esp"
			c.JSON(http.StatusOK, metro.SelectEstacionbyColor(colorEstacionEsp, idioma))
			return
		}
		if colorEstacionEn != "" {
			log.Println("Color ingles: ", colorEstacionEn)
			var idioma = "en"
			c.JSON(http.StatusOK, metro.SelectEstacionbyColor(colorEstacionEn, idioma))
			return
		}
	}
	c.JSON(http.StatusOK, metro.SelectAllEstations())
	return
}

func postEstacion(c *gin.Context) {
	var newEstacion models.Estacion
	if err := c.BindJSON(&newEstacion); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	metro.CreateEstacion(newEstacion)
	c.JSON(http.StatusOK, newEstacion)
}

func deleteEstacion(c *gin.Context) {

}

func getLinea(c *gin.Context) {
	colorLine := c.Query("color")
	idLine, err := strconv.Atoi(c.Query("idLine"))
	if err != nil && idLine != 0 {
		c.JSON(http.StatusBadRequest, err)
		return
	}
	///ID
	if idLine != 0 {
		log.Println("ID Line", idLine)
		c.JSON(http.StatusOK, metro.SelectLinesById(idLine))
		return
	}
	///Color
	if colorLine != "" {
		log.Println("Color", colorLine)
		log.Println(metro.SelectLineByColor(colorLine))
		c.JSON(http.StatusOK, metro.SelectLineByColor(colorLine))
		return
	}
	log.Println(metro.SelectAllLines())
	c.JSON(http.StatusOK, metro.SelectAllLines())
	return
}

func postLinea(c *gin.Context) {
	var newLinea models.Linea
	if err := c.BindJSON(&newLinea); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	metro.CreateLinea(newLinea)
	c.JSON(http.StatusOK, newLinea)
}

func deleteLinea(c *gin.Context) {

}
