package routes

import (
	"log"
	"net/http"

	responsegeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"

	"github.com/gin-gonic/gin"
)

func addGeoJsonRoute(rg *gin.RouterGroup) {
	//GeoJson
	rg.GET("/geojson", getGeoJsonRoute)
	/*
		rg.POST()
		rg.DELETE()
		rg.PATCH()
	*/
}
func getGeoJsonRoute(c *gin.Context) {
	data := responsegeojson.FeatureCollection{
		Type: "FeatureCollection",
		Features: []responsegeojson.Feature{{
			Type: "Feature",
			Geometry: responsegeojson.Geometry{
				Type:        "Point",
				Coordinates: []float64{-99.0868432246045, 19.3058906418396},
			},
			Properties: responsegeojson.Properties{
				EstacionID:        245,
				Nombre:            "Base Canal de Chalco",
				Tipo:              "Intermedia",
				AlcaldiaMunicipio: "Iztapalapa",
				Anio:              "1967.0",
				Sistema:           "STC Metro",
				Existe:            false,
			},
		},
		},
	}
	log.Println("RESPONSE: ", data)
	c.JSON(http.StatusOK, data)
	return
}
