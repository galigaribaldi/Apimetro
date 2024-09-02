package routes

import (
	"log"
	"net/http"
	"strconv"
	"strings"

	metro "Apimetro/cmd/pkg/controller/metro"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
)

func addLineRoute(rg *gin.RouterGroup) {

	//Lineas
	rg.GET("/linea", getLineaRoute)
	rg.POST("/linea", postLineaRoute)
	rg.DELETE("/linea", deleteLineaRoute)
	rg.PATCH("linea", updateLineaRoute)
}


/*
------
Lineas
------

Obtener datos de Lineas
*/

//  getLineaRoute   GET linea
//	@Summary		Datos de Linea
//	@Description	Obtener datos a través de los siguientes parámetros: Numero de Linea (linea_id), color en español(color_esp), color en inglés(color_eng)
//	@Tags			Linea
//	@Accept			json
//	@Produce		json
//	@Param			linea_id	query		string	false	"Search by linea_id"		Format(linea_id)
//	@Param			color_esp	query		string	false	"Search by Color Español"	Format(color_esp)
//	@Param			color_eng	query		string	false	"Search by Color Ingles"	Format(color_eng)
//	@Success		200			{object}	models.Linea
//	@Failure		400			{object}	httputil.HTTPError
//	@Failure		404			{object}	httputil.HTTPError
//	@Failure		500			{object}	httputil.HTTPError
//	@Router			/linea [get]
func getLineaRoute(c *gin.Context) {
	colorLine := strings.ToUpper(c.Query("color_esp"))
	colorLineEng := strings.ToLower(c.Query("color_eng"))
	idLine, err := strconv.Atoi(c.Query("linea_id"))
	terminalOriginal := c.Query("terminal_original")
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
	///Color Español
	if colorLine != "" {
		log.Println("Color Español", colorLine)
		log.Println(metro.SelectLineByColor(colorLine))
		c.JSON(http.StatusOK, metro.SelectLineByColor(colorLine))
		return
	}
	///Color Ingles
	if colorLineEng != "" {
		log.Println("Color ingles", colorLineEng)
		log.Println(metro.SelectLineByColorEng(colorLineEng))
		c.JSON(http.StatusOK, metro.SelectLineByColorEng(colorLineEng))
		return
	}
	// Terminal original
	if terminalOriginal != "" {
		log.Println("Terminal Original: ", terminalOriginal)
		c.JSON(http.StatusOK, metro.SelectLineabyTerminalOriginal(terminalOriginal))
		return
	}
	log.Println(metro.SelectAllLines())
	c.JSON(http.StatusOK, metro.SelectAllLines())
	return
}

// Crear una nueva Linea
func postLineaRoute(c *gin.Context) {
	var newLinea models.Linea
	if err := c.BindJSON(&newLinea); err != nil {
		log.Println(&newLinea)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	metro.CreateLinea(newLinea)
	c.JSON(http.StatusOK, newLinea)
}

// Eliminar una linea
func deleteLineaRoute(c *gin.Context) {
	ids, err := strconv.Atoi(c.Query("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, err)
	}
	metro.DeleteLinea(ids)
	c.JSON(http.StatusOK, "Estacion eliminada")
}

// Actualizar una Linea
func updateLineaRoute(c *gin.Context) {
	var newLinea models.Linea
	if err := c.BindJSON(&newLinea); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	metro.UpdateLinea(newLinea)
	c.JSON(http.StatusOK, newLinea)
}
