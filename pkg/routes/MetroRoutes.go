package routes

import (
	"log"
	"net/http"
	"strconv"

	metro "Apimetro/pkg/controller/metro"
	"Apimetro/pkg/models"

	"github.com/gin-gonic/gin"
)

func addMetterRoute(rg *gin.RouterGroup) {
	rg.GET("/estacion", getEstacion)
	rg.POST("/estacion", postEstacion)
	rg.GET("/linea", getLinea)
	rg.POST("/linea", postLinea)
}

func getEstacion(c *gin.Context) {
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
