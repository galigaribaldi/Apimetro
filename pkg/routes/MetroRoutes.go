package routes

import (
	"net/http"

	metro "github.com/galigaribaldi/Apimetro/pkg/controller/metro"
	"github.com/gin-gonic/gin"
)

func addMetterRoute(rg *gin.RouterGroup) {
	rg.GET("/metro", getEstacion)
}

func getEstacion(c *gin.Context) {

	c.JSON(http.StatusOK, metro.SelectAllEstations())
	return
}
