package models

type Linea struct {
	ID                  int                `gorm:"primary_key" json:"linea_id"`
	RouteGTFS           string             `json:"route_gtfs"`
	Nombre              string             `json:"nombre"`
	Num_comercial       string             `json:"num_comercial"`
	Sistema             string             `json:"sistema"`
	Anio_inauguracion   int                `json:"anio_inauguracion"`
	Color_en            string             `json:"color_en"`
	Color_esp           string             `json:"color_esp"`
	Tam_km              float64            `json:"tam_km"`
	Existe              bool               `json:"existe"`
	Clasificacion       string             `gorm:"default:'existente'" json:"clasificacion"`
	Ramal_id            int                `json:"ramal_id"`
	Linea_base_ramal    int                `json:"linea_base_ramal"`
	Descripcion_linea   []DescripcionLinea `gorm:"foreignKey:Linea_base;references:ID" json:"descripcion_linea"`
	Ramales             []Ramal            `gorm:"foreignKey:LineaID" json:"ramales"`
	Geom                string             `gorm:"column:geom" json:"geom"`
	JerarquiaTransporte *string            `gorm:"column:jerarquia_transporte" json:"jerarquia_transporte"`
	DerechoDeVia        *string            `gorm:"column:derecho_de_via" json:"derecho_de_via"`
	CapacidadVehiculo   *int               `gorm:"column:capacidad_vehiculo" json:"capacidad_vehiculo"`
}
