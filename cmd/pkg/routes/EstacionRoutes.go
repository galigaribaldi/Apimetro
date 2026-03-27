package routes

import (
	"log"
	"net/http"
	"strconv"

	transporte "Apimetro/cmd/pkg/controller/transporte"
	"Apimetro/cmd/pkg/models"

	"github.com/gin-gonic/gin"
	"golang.org/x/text/unicode/norm"
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
	sistema := c.MustGet("sistemaValidado").(string)
	filtros := make(map[string]interface{})

	if sistema != "TODOS" {
		filtros["sistema"] = sistema
	}
	if id := c.Query("id"); id != "" {
		filtros["id"] = id
	}
	if nombreRaw := c.Query("nombre"); nombreRaw != "" {
		// Esto fuerza a que "n" + "~" se convierta en "ñ" real
		filtros["nombre"] = norm.NFC.String(nombreRaw)
	}
	if nombre := c.Query("nombre"); nombre != "" {
		filtros["nombre"] = nombre
	}
	if lineaID := c.Query("linea_id"); lineaID != "" {
		filtros["linea_id"] = lineaID
	}
	if alcaldia := c.Query("alcaldia_municipio"); alcaldia != "" {
		filtros["alcaldia_municipio"] = alcaldia
	}
	if numComercial := c.Query("num_comercial"); numComercial != "" {
		filtros["num_comercial"] = numComercial
	}
	if colorEsp := c.Query("color_esp"); colorEsp != "" {
		filtros["color_esp"] = colorEsp
	}
	if colorEn := c.Query("color_en"); colorEn != "" {
		filtros["color_en"] = colorEn
	}

	log.Println("Buscando Estaciones con filtros:", filtros)
	resultados := transporte.SearchEstaciones(filtros)
	c.JSON(http.StatusOK, resultados)
}

// ==========================================
// POST /movilidad/:sistema/estacion
// ==========================================
func postEstacionRoute(c *gin.Context) {
	var newEstacion models.Estacion
	if err := c.BindJSON(&newEstacion); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido", "detalle": err.Error()})
		return
	}
	transporte.CreateEstacion(newEstacion)
	c.JSON(http.StatusCreated, gin.H{"mensaje": "Estación creada", "data": newEstacion})
}

// ==========================================
// DELETE /movilidad/:sistema/estacion?id=1
// ==========================================
func deleteEstacionRoute(c *gin.Context) {
	idStr := c.Query("id")
	id, err := strconv.Atoi(idStr)
	if err != nil || id == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Se requiere un ID numérico válido en el query (?id=X)"})
		return
	}

	transporte.DeleteEstacion(id)
	c.JSON(http.StatusOK, gin.H{"mensaje": "Estación eliminada con éxito"})
}

// ==========================================
// PATCH /movilidad/:sistema/estacion?id=1
// ==========================================
func updateEstacionRoute(c *gin.Context) {
	idStr := c.Query("id")
	id, err := strconv.Atoi(idStr)
	if err != nil || id == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Se requiere un ID numérico válido en el query (?id=X)"})
		return
	}

	var updateData models.Estacion
	if err := c.BindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "JSON inválido"})
		return
	}

	updateData.ID = uint(id)
	transporte.UpdateEstacion(updateData)

	c.JSON(http.StatusOK, gin.H{"mensaje": "Estación actualizada correctamente"})
}
