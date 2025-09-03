package models

// Feature representa una sola entidad del GeoJSON
type Feature struct {
	Type       string     `json:"type"`       // "Feature"
	Geometry   Geometry   `json:"geometry"`   // Geometría de tipo Point
	Properties Properties `json:"properties"` // Atributos de la estación
}
