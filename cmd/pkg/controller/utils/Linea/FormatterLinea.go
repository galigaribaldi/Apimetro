package utils

import (
	"Apimetro/cmd/pkg/models"
	"encoding/hex"
	"fmt"
	"log"

	"github.com/paulmach/orb"
	"github.com/paulmach/orb/encoding/wkb"
)

// La función ConvertLineaToFeature NO necesita cambios, ya que hace su trabajo correctamente.
func ConvertLineaToFeature(linea models.Linea) (*GeoJSONFeature, error) {
	data, err := hex.DecodeString(linea.Geom)
	if err != nil {
		log.Printf("Error al decodificar WKB (linea_id=%d): %v", linea.ID, err)
		return nil, err
	}

	geom, err := wkb.Unmarshal(data)
	if err != nil {
		log.Printf("Error al hacer unmarshal del WKB (linea_id=%d): %v", linea.ID, err)
		return nil, err
	}

	var coords [][][]float64

	switch g := geom.(type) {
	case orb.MultiLineString:
		for _, line := range g {
			var lineCoords [][]float64
			for _, pt := range line {
				lineCoords = append(lineCoords, []float64{pt.X(), pt.Y()})
			}
			coords = append(coords, lineCoords)
		}
	case orb.LineString:
		log.Printf("Geometría era LineString, convirtiendo a MultiLineString (linea_id=%d)", linea.ID)
		var lineCoords [][]float64
		for _, pt := range g {
			lineCoords = append(lineCoords, []float64{pt.X(), pt.Y()})
		}
		coords = [][][]float64{lineCoords}
	default:
		log.Printf("Tipo de geometría no compatible (linea_id=%d): %T", linea.ID, g)
		return nil, fmt.Errorf("tipo de geometría no compatible para linea_id=%d", linea.ID)
	}

	return &GeoJSONFeature{
		Type: "Feature",
		Geometry: Geometry{
			Type:        "MultiLineString",
			Coordinates: coords,
		},
		Properties: map[string]interface{}{
			"linea_id":          linea.ID,
			"nombre":            linea.Nombre,
			"sistema":           linea.Sistema,
			"anio_inauguracion": linea.Anio_inauguracion,
			"color_en":          linea.Color_en,
			"color_esp":         linea.Color_esp,
			"tam_km":            linea.Tam_km,
			"existe":            linea.Existe,
			"ramal_id":          linea.Ramal_id,
			"linea_base_ramal":  linea.Linea_base_ramal,
		},
	}, nil
}

// FUNCIÓN MODIFICADA: Devuelve el objeto FeatureCollection completo
func ConvertLineasToFeatureCollection(lineas []models.Linea) (*FeatureCollection, error) {
	// Usamos el tipo concreto de tu definición GeoJSONFeature
	var features []GeoJSONFeature
	var failedIDs []int

	for _, linea := range lineas {
		// La función ConvertLineaToFeature devuelve *GeoJSONFeature
		featurePtr, err := ConvertLineaToFeature(linea)
		if err != nil {
			log.Printf("Error convirtiendo linea_id=%d: %v", linea.ID, err)
			failedIDs = append(failedIDs, linea.ID)
			continue
		}
		// Desreferenciamos el puntero para añadir el valor al slice
		features = append(features, *featurePtr)
	}

	if len(failedIDs) > 0 {
		// Puedes decidir si devolver un error o solo los datos parciales
		log.Printf("ADVERTENCIA: Se devolvieron datos incompletos. Fallaron IDs: %v", failedIDs)
		// Continuaremos y devolveremos el FeatureCollection parcial
	}

	// AHORA CONSTRUIMOS EL OBJETO FeatureCollection ESTÁNDAR
	collection := &FeatureCollection{
		Type:     "FeatureCollection", // Clave fija
		Features: features,            // El slice de Features
	}

	return collection, nil
}
