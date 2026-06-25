package geojson

import (
	con "Apimetro/cmd/pkg/controller"
	utilsGeoJson "Apimetro/cmd/pkg/controller/utils/GeoJson"
	modelsGeojson "Apimetro/cmd/pkg/models/ResponseGeoJson"
	"encoding/json"
	"log"
	"strings"
)

// SelectGeoJsonLineaConFiltros orquesta la extracción de geometrías y métricas operativas de los ramales
func SelectGeoJsonLineaConFiltros(filtros map[string]interface{}) modelsGeojson.FeatureCollection {
	var resultados []utilsGeoJson.ResultGeoJsonLinea

	query := con.DB.Table("lineas").
		Select(`
			lineas.id AS linea_id,
			lineas.nombre AS nombre_linea,
			lineas.sistema,
			lineas.num_comercial,
			lineas.color_esp,
			lineas.tam_km,
			ramals.nombre_ramal,
			ramals.ramal_num AS sentido,
			ST_AsGeoJSON(ST_Multi(ST_Union(ramals.geom))) AS mapa,
			ST_Length(ST_Union(ramals.geom)::geography) AS distancia_metros,
			lineas.jerarquia_transporte,
			lineas.derecho_de_via,
			lineas.capacidad_vehiculo,
			h.velocidad_promedio_kmh,
			h.frecuencia_minutos,
			h.fuente
		`).
		Joins("INNER JOIN ramals ON lineas.id = ramals.linea_id").
		Joins(`LEFT JOIN (
			SELECT DISTINCT ON (ramal_id) ramal_id, velocidad_promedio_kmh, frecuencia_minutos, fuente 
			FROM historico_operacion 
			ORDER BY ramal_id, fecha_registro DESC
		) h ON ramals.id = h.ramal_id`).
		Where("ramals.geom IS NOT NULL").
		Group(`
			lineas.id,
			lineas.nombre,
			lineas.sistema,
			lineas.num_comercial,
			lineas.color_esp,
			lineas.tam_km,
			ramals.nombre_ramal,
			ramals.ramal_num,
			lineas.derecho_de_via,
			lineas.capacidad_vehiculo,
			h.velocidad_promedio_kmh,
			h.frecuencia_minutos,
			h.fuente,
			lineas.jerarquia_transporte
		`)
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
	if existe, ok := filtros["existe"]; ok {
		query = query.Where("lineas.existe = ?", existe)
	}
	// Filtrar el trazo de la línea si pasa por estaciones CETRAM
	if esCetram, ok := filtros["es_cetram"]; ok && esCetram != "" {
		query = query.Joins("JOIN estacions ON estacions.linea_id = lineas.id").
			Where("estacions.es_cetram = ?", esCetram)
	}
	// Filtrar por sentido (IDA o REGRESO)
	if sentido, ok := filtros["sentido"]; ok && sentido != "" {
		sentidoVal := strings.ToUpper(sentido.(string))
		if sentidoVal == "IDA" {
			query = query.Where("ramals.ramal_num = ?", 1)
		} else if sentidoVal == "REGRESO" {
			query = query.Where("ramals.ramal_num = ?", 0)
		}
	}
	// Separar los parámetros por comas
	if nr, ok := filtros["nombre_ramal"]; ok && nr != "" {
		ramales := strings.Split(nr.(string), ",")

		var condiciones []string
		var valores []interface{}

		for _, ramal := range ramales {
			condiciones = append(condiciones, "ramals.nombre_ramal ILIKE ?")
			valores = append(valores, "%"+strings.TrimSpace(ramal)+"%")
		}

		query = query.Where(strings.Join(condiciones, " OR "), valores...)
	}

	// TODO: Implementar filtro cetram_real (búsqueda espacial 250m)
	// if cetramReal, ok := filtros["cetram_real"]; ok && cetramReal != "" {
	//     // Implementar consulta espacial para encontrar líneas dentro de 250m de un cetram
	// }

	if result := query.Scan(&resultados); result.Error != nil {
		log.Println("Error obteniendo GeoJson de líneas", result.Error)
		return modelsGeojson.FeatureCollection{}
	}

	featureCollection := modelsGeojson.FeatureCollection{
		Type:     "FeatureCollection",
		Features: []modelsGeojson.Feature{},
	}

	// Parseo a Feature
	for _, row := range resultados {
		var geometry modelsGeojson.Geometry
		if err := json.Unmarshal([]byte(row.Mapa), &geometry); err != nil {
			log.Println("Error Parseando geometría del ramal:", row.NombreRamal, err)
			continue
		}

		propertys := map[string]interface{}{
			"linea_id":               row.LineaID,
			"nombre_linea":           row.NombreLinea,
			"sistema":                row.Sistema,
			"color_esp":              row.ColorEsp,
			"tam_km":                 row.TamKm,
			"nombre_ramal":           row.NombreRamal,
			"tipo_entidad":           "ruta", // Constante dictada por el modelo VFT
			"sentido":                row.Sentido,
			"jerarquia_transporte":   row.JerarquiaTransporte,
			"distancia_metros":       row.DistanciaMetros,
			"derecho_de_via":         row.DerechoDeVia,
			"capacidad_vehiculo":     row.CapacidadVehiculo,
			"velocidad_promedio_kmh": row.VelocidadPromedioKmh,
			"frecuencia_minutos":     row.FrecuenciaMinutos,
			"fuente":                 row.Fuente,
		}

		feature := modelsGeojson.Feature{
			Type:       "Feature",
			Geometry:   geometry,
			Properties: propertys,
		}

		featureCollection.Features = append(featureCollection.Features, feature)
	}

	return featureCollection
}
