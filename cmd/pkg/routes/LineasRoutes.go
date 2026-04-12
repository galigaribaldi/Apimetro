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

// addLineRoute configura las rutas para la API, teniendo en cuenta
// la arquitectura dinámica dependiendo del sistema de transporte
//
//	@Summary		Líneas
//	@Description		Obtener, crear, actualizar y eliminar líneas
//	@Tags			Línea
func addLineRoute(rg *gin.RouterGroup) {

	//Lineas
	rg.GET("/linea", getLineaRoute)
	rg.POST("/linea", postLineaRoute)
	rg.DELETE("/linea", deleteLineaRoute)
	rg.PATCH("/linea", updateLineaRoute)
}

// ==========================================
// GET /movilidad/{sistema}/linea
// ==========================================
// getLineaRoute   	GET Route
//
//	@Summary		Consultar Líneas de Transporte
//	@Description	Retorna datos descriptivos (JSON) de líneas de transporte del sistema indicado en la ruta.
//	@Description	Si el sistema es TODOS, devuelve líneas de todos los sistemas disponibles.
//	@Description	Los filtros de texto usan búsqueda parcial insensible a mayúsculas (ILIKE) y soportan caracteres especiales.
//	@Description	Los resultados incluyen relaciones anidadas: ramales y descripciones de línea.
//	@Tags			Linea
//	@Accept			json
//	@Produce		json
//	@Param			sistema			path	string	true	"Sistema de transporte. Valores: METRO, MB, CBB, RTP, TROLE, TL, MEXIBUS, MEXICABLE, INTERURBANO, CC, TODOS"
//	@Param			id				query	int		false	"ID interno de la línea en la base de datos"
//	@Param			nombre			query	string	false	"Nombre descriptivo de la línea (ej: 'Línea 1', 'Línea A'). Búsqueda parcial."
//	@Param			num_comercial	query	string	false	"Número o clave comercial visible al usuario (ej: '1', 'A', 'MB1')"
//	@Param			nombre_ramal	query	string	false	"Nombre del ramal o variante de ruta (ej: 'Ramal Politécnico')"
//	@Param			clasificacion	query	string	false	"Clasificación operativa. Valores: existente, eliminada, futura"
//	@Param			tam_km			query	string	false	"Longitud total de la línea en kilómetros (ej: '18.8')"
//	@Param			existe			query	bool	false	"true = líneas en operación activa, false = líneas discontinuadas"
//	@Param			es_cetram		query	string	false	"Filtra líneas con estaciones tipo CETRAM. Valores: true, false"
//	@Param			sentido			query	string	false	"Dirección del trazo. Valores: 1 (ida), 0 (regreso)"
//	@Success		200				{array}		models.Linea			"Lista de líneas que coinciden con los filtros"
//	@Failure		400				{object}	map[string]interface{}	"Parámetros inválidos en la solicitud"
//	@Failure		404				{object}	map[string]interface{}	"No se encontraron líneas con los filtros dados"
//	@Failure		500				{object}	map[string]interface{}	"Error interno del servidor"
//	@Router			/{sistema}/linea [get]
func getLineaRoute(c *gin.Context) {

	sistema := c.MustGet("sistemaValidado").(string)
	filtros := make(map[string]interface{})

	if sistema != "TODOS" {
		filtros["sistema"] = sistema
	}
	// Capturar los Query Params
	// Soporte para caracteres nuevos
	if nombreRaw := c.Query("nombre"); nombreRaw != "" {
		// Esto fuerza a que "n" + "~" se convierta en "ñ" real
		filtros["nombre"] = norm.NFC.String(nombreRaw)
	}
	if nombre := c.Query("nombre"); nombre != "" {
		filtros["nombre"] = nombre
	}

	if ramal := c.Query("nombre_ramal"); ramal != "" {
		ramalNormalizado := norm.NFC.String(ramal)
		filtros["nombre_ramal"] = ramalNormalizado
	}

	if numComercial := c.Query("num_comercial"); numComercial != "" {
		filtros["num_comercial"] = numComercial
	}

	if clasificacion := c.Query("clasificacion"); clasificacion != "" {
		filtros["clasificacion"] = clasificacion
	}

	if tamKm := c.Query("tam_km"); tamKm != "" {
		filtros["tam_km"] = tamKm
	}
	// Filtrar por si la línea tiene estaciones tipo CETRAM
	if esCetram := c.Query("es_cetram"); esCetram != "" {
		filtros["es_cetram"] = esCetram
	}
	// Filtrar por sentido
	if sentido := c.Query("sentido"); sentido != "" {
		filtros["sentido"] = sentido
	}

	if existeStr := c.Query("existe"); existeStr != "" {
		existe, err := strconv.ParseBool(existeStr)
		if err == nil {
			filtros["existe"] = existe
		}
	}
	log.Println("🔍 Filtros detectados en la petición:", filtros)
	lineas := transporte.SearchLineas(filtros)
	c.JSON(http.StatusOK, lineas)
}

// ==========================================
// POST /movilidad/{sistema}/linea
// ==========================================
// postLineaRoute   	POST Route
//
//	@Summary		Crear Línea de Transporte
//	@Description	Crea un nuevo registro de línea de transporte en el sistema.
//	@Description	Si no se especifica `sistema` en el body, se asigna 'METRO' por defecto.
//	@Description	La geometría (`geom`) debe enviarse en formato WKT (Well-Known Text) si se incluye.
//	@Tags			Linea
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path	string		true	"Sistema de transporte"
//	@Param			linea	body	models.Linea	true	"Objeto Linea con los datos a registrar. Campos requeridos: nombre, sistema."
//	@Success		201		{object}	models.Linea			"Línea creada exitosamente"
//	@Failure		400		{object}	map[string]interface{}	"JSON inválido o campos requeridos faltantes"
//	@Failure		500		{object}	map[string]interface{}	"Error interno al guardar en la base de datos"
//	@Router			/{sistema}/linea [post]
func postLineaRoute(c *gin.Context) {
	var newLinea models.Linea

	if err := c.BindJSON(&newLinea); err != nil {
		c.JSON(http.StatusBadRequest,
			gin.H{
				"error":   "JSON inválido",
				"detalle": err.Error(),
			})
		return
	}

	if newLinea.Sistema == "" {
		newLinea.Sistema = "METRO"
	}

	if err := transporte.CreateLinea(newLinea); err != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{
				"error":   "No se pudo crear la línea",
				"detalle": err.Error(),
			},
		)
		return
	}
	c.JSON(http.StatusCreated, newLinea)

}

// ==========================================
// DELETE /movilidad/{sistema}/linea?id=1
// ==========================================
// deleteLineaRoute   	DELETE Route
//
//	@Summary		Eliminar Línea de Transporte
//	@Description	Elimina una línea por su ID interno. La operación es en cascada: también elimina
//	@Description	los Ramales y las DescripcionLinea asociados a esa línea.
//	@Description	Esta operación es irreversible.
//	@Tags			Linea
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path	string	true	"Sistema de transporte"
//	@Param			id		query	int		true	"ID interno de la línea a eliminar (ej: ?id=5)"
//	@Success		200		{object}	map[string]interface{}	"Línea y dependencias eliminadas correctamente"
//	@Failure		400		{object}	map[string]interface{}	"ID inválido o faltante"
//	@Failure		500		{object}	map[string]interface{}	"Error interno al eliminar de la base de datos"
//	@Router			/{sistema}/linea [delete]
func deleteLineaRoute(c *gin.Context) {
	idStr := c.Query("id")
	id, err := strconv.Atoi(idStr)

	if err != nil || id == 0 {
		c.JSON(
			http.StatusBadRequest,
			gin.H{
				"error": "Se requiere un ID numérico válido (ej. ?id=1)",
			})
		return
	}

	if err := transporte.DeleteLinea(id); err != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{
				"error": "No se pudo eliminar la línea",
			})
		return
	}
	c.JSON(http.StatusOK, gin.H{"mensaje": "Línea y dependencias eliminadas correctamente"})
}

// ==========================================
// PATCH /movilidad/{sistema}/linea?id=1
// ==========================================
// updateLineaRoute   	PATCH Route
//
//	@Summary		Actualizar Línea de Transporte
//	@Description	Actualiza parcialmente los datos de una línea por su ID interno.
//	@Description	Solo se actualizan los campos enviados en el body (PATCH semántico).
//	@Description	El campo `linea_id` es ignorado aunque se envíe en el body (protección de integridad).
//	@Tags			Linea
//	@Accept			json
//	@Produce		json
//	@Param			sistema	path	string					true	"Sistema de transporte"
//	@Param			id		query	int						true	"ID interno de la línea a actualizar (ej: ?id=5)"
//	@Param			linea	body	map[string]interface{}	true	"Campos a actualizar. Ej: {\"nombre\": \"Línea 1 Actualizada\", \"existe\": true}"
//	@Success		200		{object}	map[string]interface{}	"Línea actualizada correctamente"
//	@Failure		400		{object}	map[string]interface{}	"ID inválido o JSON mal formado"
//	@Failure		500		{object}	map[string]interface{}	"Error interno al actualizar en la base de datos"
//	@Router			/{sistema}/linea [patch]
func updateLineaRoute(c *gin.Context) {
	idStr := c.Query("id")
	id, err := strconv.Atoi(idStr)

	if err != nil || id == 0 {
		c.JSON(
			http.StatusBadRequest,
			gin.H{
				"error": "Se requiere un ID numérico válido (ej. ?id=1)",
			},
		)
		return
	}

	var dataActualizada map[string]interface{}
	if err := c.BindJSON(&dataActualizada); err != nil {
		c.JSON(
			http.StatusBadRequest,
			gin.H{
				"error": "JSON inválido",
			},
		)
	}

	delete(dataActualizada, "linea_id")

	if err := transporte.UpdateLinea(id, dataActualizada); err != nil {
		c.JSON(
			http.StatusInternalServerError,
			gin.H{
				"error": "No se pudo actualizar la línea",
			})
		return
	}
	c.JSON(http.StatusOK, gin.H{"mensaje": "Línea actualizada correctamente"})
}
