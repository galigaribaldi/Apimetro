package models

// Ramal representa una versión específica de la ruta de una Línea de metro.
type Ramal struct {
	ID            int     `gorm:"primary_key" json:"ramal_id"`
	LineaID       int     `gorm:"index;column:linea_id" json:"linea_id"`
	ShapeGTFS     string  `json:"shape_gtfs"`
	NombreRamal   string  `json:"nombre_ramal"`
	Tam_km        float64 `json:"tam_km"`
	Geom          string  `gorm:"column:geom;type:geometry(MultiLineString, 4326)" json:"geom"`
	Anio_creacion int     `json:"anio_creacion"`
	Ramal_num     int     `json:"ramal_num"`
	Estado        string  `gorm:"type:estado_ramal" json:"estado"`
}

// **********************************************
// RESTRICCIÓN CLAVE: Uso de gorm:"type:ENUM(...)"
// **********************************************
