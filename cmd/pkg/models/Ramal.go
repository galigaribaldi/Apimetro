package models

// Ramal representa una versión específica de la ruta de una Línea de metro.
type Ramal struct {
	ID            int     `gorm:"primary_key" json:"ramal_id" example:"1"`
	LineaID       int     `gorm:"index;column:linea_id" json:"linea_id" example:"1"`
	ShapeGTFS     string  `json:"shape_gtfs" example:"STC_L1_IDA"`
	NombreRamal   string  `json:"nombre_ramal" example:"IDA"`
	Tam_km        float64 `json:"tam_km" example:"18.8"`
	Geom          string  `gorm:"column:geom;type:geometry(MultiLineString, 4326)" json:"geom" example:"MULTILINESTRING((-99.188 19.403, -99.190 19.405))"`
	Anio_creacion int     `json:"anio_creacion" example:"1969"`
	Ramal_num     int     `json:"ramal_num" example:"1"`
	Estado        string  `gorm:"type:estado_ramal" json:"estado" example:"activo"`
}

// **********************************************
// RESTRICCIÓN CLAVE: Uso de gorm:"type:ENUM(...)"
// **********************************************
