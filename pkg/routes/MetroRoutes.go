package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func addMetterRoute(rg *gin.RouterGroup) {
	rg.GET("/metro", getMetro)
}

func getMetro(c *gin.Context) {

	c.JSON(http.StatusOK, gin.H{
		"code":    0,
		"message": "It Works!",
		"data":    "",
	})
	return
}
