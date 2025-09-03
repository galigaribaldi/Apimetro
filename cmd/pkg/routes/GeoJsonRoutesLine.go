package routes

import (
	metro "Apimetro/cmd/pkg/controller/metro"
	utilsFormatterLinea "Apimetro/cmd/pkg/controller/utils/Linea"
	"log"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func addGeoJsonRouteLine(rg *gin.RouterGroup) {
	rg.GET("/geojsonLinea", getGeoJsonRouteLinea)
}
func getGeoJsonRouteLinea(c *gin.Context) {
	//colorLine := strings.ToUpper(c.Query("color_esp"))
	//colorLineEng := strings.ToLower(c.Query("color_eng"))
	idLine, err := strconv.Atoi(c.Query("linea_id"))
	//terminalOriginal := c.Query("terminal_original")

	if err != nil && idLine != 0 {
		c.JSON(http.StatusBadRequest, err)
		return
	}
	///ID
	if idLine != 0 {
		log.Println("ID Line", idLine)
		dataidLinea := metro.SelectLinesById(idLine)
		data, err := utilsFormatterLinea.ConvertLineaToFeature(dataidLinea)
		if err != nil {
			log.Printf("Error convirtiendo línea a GeoJSON %v", err)
			c.JSON(http.StatusBadRequest, err)
			return
		}
		c.JSON(http.StatusOK, data)
		return
	}
	dataLinea := metro.SelectAllLines()
	data, err := utilsFormatterLinea.ConvertLineasToFeatureCollection(dataLinea)
	if err != nil {
		log.Printf("Error convirtiendo línea a GeoJSON %v", err)
		c.JSON(http.StatusBadRequest, err)
		return
	}
	c.JSON(http.StatusOK, data)

	return
}
