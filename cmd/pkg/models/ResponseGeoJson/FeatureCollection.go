package models

// FeatureCollection es el objeto completo GeoJSON
type FeatureCollection struct {
	Type     string    `json:"type" example:"FeatureCollection"` // "FeatureCollection"
	Features []Feature `json:"features"`                        // Lista de features (líneas o estaciones)
}
