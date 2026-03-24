package models

// Geometry representa la parte geométrica del GeoJSON (Soporta Point, LineString, MultiLineString)

type Geometry struct {
	Type        string      `json:"type"`        // "Point"
	Coordinates interface{} `json:"coordinates"` // interface{} permite múltiples niveles de arreglos
}
