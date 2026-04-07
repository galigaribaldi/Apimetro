package models

// Linea represents a transportation line in the STC system
type Linea struct {
	ID                  int                `gorm:"primary_key" json:"linea_id" example:"1"`
	RouteGTFS           string             `json:"route_gtfs" example:"L1"`
	Nombre              string             `json:"nombre" example:"Línea 1"`
	Num_comercial       string             `json:"num_comercial" example:"1"`
	Sistema             string             `json:"sistema" example:"METRO"`
	Anio_inauguracion   int                `json:"anio_inauguracion" example:"1969"`
	Color_en            string             `json:"color_en" example:"Pink"`
	Color_esp           string             `json:"color_esp" example:"Rosa"`
	Tam_km              float64            `json:"tam_km" example:"18.8"`
	Existe              bool               `json:"existe" example:"true"`
	Clasificacion       string             `gorm:"default:'existente'" json:"clasificacion" example:"existente"`
	Ramal_id            int                `json:"ramal_id" example:"1"`
	Linea_base_ramal    int                `json:"linea_base_ramal" example:"1"`
	Descripcion_linea   []DescripcionLinea `gorm:"foreignKey:Linea_base;references:ID" json:"descripcion_linea"`
	Ramales             []Ramal            `gorm:"foreignKey:LineaID" json:"ramales"`
	Geom                string             `gorm:"column:geom" json:"geom" example:"MULTILINESTRING(...)"`
	JerarquiaTransporte *string            `gorm:"column:jerarquia_transporte" json:"jerarquia_transporte" example:"Línea principal"`
	DerechoDeVia        *string            `gorm:"column:derecho_de_via" json:"derecho_de_via" example:"Superficie"`
	CapacidadVehiculo   *int               `gorm:"column:capacidad_vehiculo" json:"capacidad_vehiculo" example:"1000"`
}
