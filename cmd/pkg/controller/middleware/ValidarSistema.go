package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// Diccionario estático de sistemas válidos
var sistemasValidos = map[string]bool{
	"METRO": true,
	"MB":    true,
	"CB":    true,
	"RTP":   true,
	"TROLE": true,
	"TL":    true,
	"TODOS": true,
}

func ValidarSistema() gin.HandlerFunc {
	return func(c *gin.Context) {
		sistemaParam := c.Param("sistema")
		sistemaUpper := strings.ToUpper(sistemaParam)
		if !sistemasValidos[sistemaUpper] {
			c.AbortWithStatusJSON(http.StatusNotFound, gin.H{
				"error":   "Sistema de transporte no Encontrado",
				"mensaje": "El sistema'" + sistemaParam + "' no",
			})
			return
		}
		c.Set("sistemaValidado", sistemaUpper)
		c.Next()
	}
}
