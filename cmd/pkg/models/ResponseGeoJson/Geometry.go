package models

// Geometry representa la parte geométrica del GeoJSON (Point)
type Geometry struct {
	Type        string    `json:"type"`        // "Point"
	Coordinates []float64 `json:"coordinates"` // [long, lat]
}
