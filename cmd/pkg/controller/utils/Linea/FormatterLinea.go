package utils

import (
	"Apimetro/cmd/pkg/models"
	"encoding/hex"
	"fmt"
	"log"

	"github.com/paulmach/orb"
	"github.com/paulmach/orb/encoding/wkb"
)

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

func ConvertLineasToFeatureCollection(lineas []models.Linea) ([]*GeoJSONFeature, error) {
	var features []*GeoJSONFeature
	var failedIDs []int

	for _, linea := range lineas {
		feature, err := ConvertLineaToFeature(linea)
		if err != nil {
			log.Printf("Error convirtiendo linea_id=%d: %v", linea.ID, err)
			failedIDs = append(failedIDs, linea.ID)
			continue
		}
		features = append(features, feature)
	}

	if len(failedIDs) > 0 {
		return features, fmt.Errorf("algunas líneas fallaron al convertir: %v", failedIDs)
	}

	return features, nil
}
