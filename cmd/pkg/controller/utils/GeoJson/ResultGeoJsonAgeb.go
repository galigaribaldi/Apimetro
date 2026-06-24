package geojson

type ResultGeoJsonAgeb struct {
	CveAgeb            string   `gorm:"column:cve_ageb"`
	Entidad            string   `gorm:"column:entidad"`
	MunicipioAlcaldia  *string  `gorm:"column:municipio_alcaldia"`
	PoblacionTotal     int      `gorm:"column:poblacion_total"`
	ViviendasHabitadas int      `gorm:"column:viviendas_habitadas"`
	Pea                *int     `gorm:"column:pea"`
	AreaKm2            *float64 `gorm:"column:area_km2"`
	DensidadPobKm2     *float64 `gorm:"column:densidad_pob_km2"`
	Fuente             string   `gorm:"column:fuente"`
	Mapa               string   `gorm:"column:mapa"`
}
