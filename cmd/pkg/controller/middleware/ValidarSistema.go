package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// Diccionario estático de sistemas válidos
var sistemasValidos = map[string]bool{
	"METRO":       true,
	"MB":          true,
	"CBB":         true,
	"RTP":         true,
	"TROLE":       true,
	"TL":          true,
	"TODOS":       true,
	"MEXIBÚS":     true,
	"MEXICABLE":   true,
	"INTERURBANO": true,
	"CC":          true,
	"SUB":         true,
}

// ValidarSistema es un middleware que verifica si el sistema de transporte proporcionado
// en la ruta es válido. Si no lo es, devuelve un status 404 con un objeto JSON que contiene
// el error y el mensaje de error. Si es válido, agrega una variable "sistemaValidado"
// al contexto con el valor del sistema en mayúsculas.
func ValidarSistema() gin.HandlerFunc {
	return func(c *gin.Context) {
		sistemaParam := c.Param("sistema")
		sistemaUpper := strings.ToUpper(sistemaParam)
		if !sistemasValidos[sistemaUpper] {
			c.AbortWithStatusJSON(http.StatusNotFound, gin.H{
				"error":   "Sistema de transporte no Encontrado",
				"mensaje": "El sistema'" + sistemaParam + "' no existe",
			})
			return
		}
		c.Set("sistemaValidado", sistemaUpper)
		c.Next()
	}
}
