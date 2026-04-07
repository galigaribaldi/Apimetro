package models

// Feature representa una sola entidad del GeoJSON

type Feature struct {
	Type       string                 `json:"type" example:"Feature"`       // "Feature"
	Geometry   Geometry               `json:"geometry"`                     // Geometría de tipo Point
	Properties map[string]interface{} `json:"properties"`                   // Atributos dinámicos
}
