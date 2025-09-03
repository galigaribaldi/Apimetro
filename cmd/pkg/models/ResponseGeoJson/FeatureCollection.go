package models

// FeatureCollection es el objeto completo GeoJSON
type FeatureCollection struct {
	Type     string    `json:"type"`     // "FeatureCollection"
	Features []Feature `json:"features"` // Lista de estaciones
}
