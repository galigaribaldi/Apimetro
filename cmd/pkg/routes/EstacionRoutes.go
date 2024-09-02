package routes

import (
	"fmt"
	"log"
	"net/http"
	"strconv"
	"strings"

	metro "Apimetro/cmd/pkg/controller/metro"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
)

func addEstacionRoute(rg *gin.RouterGroup) {

	//Estaciones
	rg.GET("/estacion", getEstacionRoute)
	rg.POST("/estacion", postEstacionRoute)
	rg.DELETE("/estacion", deleteEstacionRoute)
	rg.PATCH("/estacion", updateEstacionRoute)

}

/*
------
Estaciones
------

Obtener datos de Estaciones
*/

// getEstacionRoute   	GET Route
//
//	@Summary		Datos de Estacion
//	@Description	Obtener datos a través de los siguientes parámetros: Numero de Linea (linea_id), color en español(color_esp), color en inglés(color_eng)
//	@Tags			Estacion
//	@Accept			json
//	@Produce		json
//	@Param			nombre		query		string	false	"Search by nombre"			Format(nombre)
//	@Param			anio		query		string	false	"Search by anio"			Format(anio)
//	@Param			color_en	query		string	false	"Search by Color Ingles"	Format(color_en)
//	@Success		200			{object}	models.Estacion
//	@Failure		400			{object}	httputil.HTTPError
//	@Failure		404			{object}	httputil.HTTPError
//	@Failure		500			{object}	httputil.HTTPError
//	@Router			/estacion [get]
func getEstacionRoute(c *gin.Context) {
	nombreEstacion := c.Query("nombre")
	anioEstacion := c.Query("anio")
	anioAntes := c.Query("anio_antes")
	anioDespues := c.Query("anio_despues")
	ciudadEstacion := c.Query("ciudad")
	alacaldiaMunicipio := c.Query("alacaldia_municipio")
	colorEstacionEsp := strings.ToUpper(c.Query("color_esp"))
	colorEstacionEn := strings.ToUpper(c.Query("color_en"))
	idLinea, err := strconv.Atoi(c.Query("linea_id"))
	fmt.Println("Linea: ", idLinea)
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

// Crear una nueva estacion
func postEstacionRoute(c *gin.Context) {
	var newEstacion models.Estacion
	if err := c.BindJSON(&newEstacion); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	metro.CreateEstacion(newEstacion)
	c.JSON(http.StatusOK, newEstacion)
}

// Eliminar una estacion
func deleteEstacionRoute(c *gin.Context) {
	ids, err := strconv.Atoi(c.Query("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, err)
	}
	metro.DeleteEstacion(ids)
	c.JSON(http.StatusOK, "Estacion eliminada")
}

// Actualizar estaciones
func updateEstacionRoute(c *gin.Context) {
	var newEstacion models.Estacion
	if err := c.BindJSON(&newEstacion); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	metro.UpdateEstacion(newEstacion)
	c.JSON(http.StatusOK, newEstacion)
}
