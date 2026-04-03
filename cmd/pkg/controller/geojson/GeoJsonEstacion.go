package geojson

import (
	con "Apimetro/cmd/pkg/controller"
	utilsGeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	modelsGeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
	"encoding/json"
	"log"
	"strings"
)

func SelectGeoJsonEstacionConFiltros(filtros map[string]interface{}) modelsGeojson.FeatureCollection {
	var resultados []utilsGeoJson.ResultGeoJsonEstacion

	query := con.DB.Table("estacions").
		Select(`
			estacions.nombre, 
			lineas.sistema, 
			lineas.num_comercial,
			estacions.tipo, 
			estacions.alcaldia_municipio, 
			ST_AsGeoJSON(estacions.geom) AS mapa,
			lineas.jerarquia_transporte,
			estacions.es_cetram,
			estacions.nombre_cetram
		`).
		Joins("INNER JOIN lineas ON estacions.linea_id = lineas.id").
		Where("estacions.geom IS NOT NULL").
		Distinct()

	// Dividir filtros por sistema (poner varios sistemas)
	if sis, ok := filtros["sistema"]; ok && sis != "" && sis != "%" {
		sistemas := strings.Split(sis.(string), ",")

		var condiciones []string
		var valores []interface{}

		for _, s := range sistemas {
			condiciones = append(condiciones, "lineas.sistema ILIKE ?")
			valores = append(valores, strings.TrimSpace(s))
		}

		query = query.Where(strings.Join(condiciones, " OR "), valores...)
	}
	if nc, ok := filtros["num_comercial"]; ok && nc != "" {
		query = query.Where("lineas.num_comercial = ?", nc)
	}
	if alc, ok := filtros["alcaldia_municipio"]; ok && alc != "" {
		query = query.Where("estacions.alcaldia_municipio ILIKE ?", "%"+alc.(string)+"%")
	}
	if existe, ok := filtros["existe"]; ok {
		query = query.Where("lineas.existe = ?", existe)
	}
	if nr, ok := filtros["nombre_ramal"]; ok && nr != "" {
		ramales := strings.Split(nr.(string), ",")

		var condiciones []string
		var valores []interface{}

		for _, ramal := range ramales {
			condiciones = append(condiciones, "ramals.nombre_ramal ILIKE ?")
			valores = append(valores, "%"+strings.TrimSpace(ramal)+"%") // TrimSpace quita espacios accidentales
		}

		query = query.Joins("INNER JOIN ramals ON lineas.id = ramals.linea_id").
			Where(strings.Join(condiciones, " OR "), valores...)
	}

	if isCetram, ok := filtros["es_cetram"]; ok && isCetram != "" {
		query = query.Where("estacions.es_cetram = ?", isCetram)
	}

	// Filtro por nombre_cetram (Búsqueda por texto)
	if nomCetram, ok := filtros["nombre_cetram"]; ok && nomCetram != "" {
		query = query.Where("estacions.nombre_cetram ILIKE ?", "%"+strings.TrimSpace(nomCetram.(string))+"%")
	}

	if result := query.Scan(&resultados); result.Error != nil {
		log.Println("Error obteniendo GeoJson de estaciones", result.Error)
		return modelsGeojson.FeatureCollection{}
	}

	featureCollection := modelsGeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: []modelsGeojson.Feature{},
	}

	for _, row := range resultados {
		var geometry modelsGeojson.Geometry
		if err := json.Unmarshal([]byte(row.Mapa), &geometry); err != nil {
			log.Println("Error Parseando geometría de la estación", row.Nombre, err)
			continue
		}
		propertys := map[string]interface{}{
			"nombre":               row.Nombre,
			"sistema":              row.Sistema,
			"tipo":                 row.Tipo,
			"alcaldia_municipio":   row.AlcaldiaMunicipio,
			"tipo_entidad":         "estacion",
			"jerarquia_transporte": row.JerarquiaTransporte,
			"es_cetram":            row.EsCetram,
		}
		// Como NombreCetram es un puntero (*string), debemos validarlo para evitar panic si es nil
		if row.NombreCetram != nil {
			propertys["nombre_cetram"] = *row.NombreCetram
		} else {
			propertys["nombre_cetram"] = nil
		}
		featureCollection.Features = append(featureCollection.Features, modelsGeojson.Feature{
			Type:       "Feature",
			Geometry:   geometry,
			Properties: propertys,
		})
	}
	return featureCollection
}
