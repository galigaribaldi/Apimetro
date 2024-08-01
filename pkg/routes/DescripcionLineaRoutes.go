package routes

import (
	"log"
	"net/http"
	"strconv"
	//"strings"

	descripcion "Apimetro/pkg/controller/descripcion"
	"Apimetro/pkg/models"

	"github.com/gin-gonic/gin"
)


func addDescriptionRoute(rg *gin.RouterGroup){
	//Estaciones
	rg.GET("/descripcion", getDescripcionLineaRoute)
	rg.POST("/descripcion", postDescripcionLineaRoute)
}


/*
--------
GET METHOD
--------
*/

func getDescripcionLineaRoute(c *gin.Context){
	terminalOriginal := c.Query("terminal_original")
	//inicioOriginal := c.Query("inicio_original")
	lineaBase := c.Query("linea_base")
	descripcionLineaId, err := strconv.Atoi(c.Query("descripcion_linea_id"))
	if err != nil && descripcionLineaId != 0 {
		c.JSON(http.StatusBadRequest, err)
		return
	}
	//Descripcion Linea ID
	if descripcionLineaId != 0 {
		log.Println("Descripcion Linea ID: ", descripcionLineaId)
		c.JSON(http.StatusOK, descripcion.SelectDescripcionById(descripcionLineaId))
		return
	}
	//Terminal Original
	if terminalOriginal != "" {
		log.Println("Terminal Original: ", terminalOriginal)
		c.JSON(http.StatusOK, descripcion.SelectTerminalOriginal(terminalOriginal))
		return
	
	}
	//linea Base
	if lineaBase != "" {
		log.Println("Linea Base: ", lineaBase)
		c.JSON(http.StatusOK, descripcion.SelectLineaBase(lineaBase))
		return
	
	}
	c.JSON(http.StatusOK, descripcion.SelectAllDescription())	
}

/*
--------
POST METHODS
--------
*/
func postDescripcionLineaRoute(c *gin.Context){
	var newDescripcionLinea models.DescripcionLinea
	if err:= c.BindJSON(&newDescripcionLinea); err != nil{
		log.Println(&newDescripcionLinea)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	descripcion.CreateDescripcionLinea(newDescripcionLinea)
	c.JSON(http.StatusOK, newDescripcionLinea)
}