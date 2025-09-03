package routes

import (
	"log"
	"net/http"
	"strconv"

	metro "Apimetro/cmd/pkg/controller/metro"
	utilsFormatterEstacion "Apimetro/cmd/pkg/controller/utils/Estacion"

	"github.com/gin-gonic/gin"
)

func addGeoJsonRouteEstacion(rg *gin.RouterGroup) {
	//GeoJson
	rg.GET("/geojsonEstacion", getGeoJsonRouteEstacion)
	/*
		rg.POST()
		rg.DELETE()
		rg.PATCH()
	*/
}

func getGeoJsonRouteEstacion(c *gin.Context) {
	//Obtener datos por el query
	idLinea, err := strconv.Atoi(c.Query("linea_id"))
	nombreEstacion := c.Query("nombre")
	ciudadEstacion := c.Query("ciudad")
	alacaldiaMunicipio := c.Query("alacaldia_municipio")

	log.Println("Linea: ", idLinea)
	if err != nil && idLinea != 0 {
		c.JSON(http.StatusBadRequest, err)
		return
	}
	//Obtener datos por Linea ID
	if idLinea != 0 {
		log.Println("Linea ID: ", idLinea)
		dataidLineaEstacion := metro.SelectEstacionbyLineaID(idLinea)
		data := utilsFormatterEstacion.ConvertEstacionToJson(dataidLineaEstacion)
		c.JSON(http.StatusOK, data)
		return
	}
	//Obtener datos por nombre de la estacion
	if nombreEstacion != "" {
		log.Println("Nombre de la estacion: ", nombreEstacion)
		dataNombreEstacion := metro.SelectEstacionbyName(nombreEstacion)
		data := utilsFormatterEstacion.ConvertEstacionToJson(dataNombreEstacion)
		c.JSON(http.StatusOK, data)
		return
	}
	// Localizacion Estado Ciudad
	if ciudadEstacion != "" {
		log.Println("Estado - Ciudad: ", ciudadEstacion)
		dataciudadEstacion := metro.SelectEstacionbyCiudad(ciudadEstacion)
		data := utilsFormatterEstacion.ConvertEstacionToJson(dataciudadEstacion)
		c.JSON(http.StatusOK, data)
		return
	}
	// Localizacion Alcaldia o municipio
	if alacaldiaMunicipio != "" {
		log.Println("Alcaldia o municipio: ", alacaldiaMunicipio)
		dataalacaldiaMunicipio := metro.SelectEstacionbyAlcaldia(alacaldiaMunicipio)
		data := utilsFormatterEstacion.ConvertEstacionToJson((dataalacaldiaMunicipio))
		c.JSON(http.StatusOK, data)
		return
	}
	//Obtener datos de la base ((TODOS))
	dataAllEstacion := metro.SelectAllEstations()
	log.Println(dataAllEstacion)
	//Formatear datos para hacerlo en un arreglo
	data := utilsFormatterEstacion.ConvertEstacionToJson(dataAllEstacion)
	c.JSON(http.StatusOK, data)
	return
}
