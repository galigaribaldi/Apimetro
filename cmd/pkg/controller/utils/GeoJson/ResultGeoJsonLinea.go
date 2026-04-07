package geojson

type ResultGeoJsonLinea struct {
	NombreLinea          string   `gorm:"column:nombre_linea"`
	Sistema              string   `gorm:"column:sistema"`
	NumComercial         string   `gorm:"column:num_comercial"`
	ColorEsp             string   `gorm:"column:color_esp"`
	TamKm                float64  `gorm:"column:tam_km"`
	NombreRamal          string   `gorm:"column:nombre_ramal"`
	Mapa                 string   `gorm:"column:mapa"`
	DistanciaMetros      *float64 `gorm:"column:distancia_metros"`
	JerarquiaTransporte  *string  `gorm:"column:jerarquia_transporte"`
	DerechoDeVia         *string  `gorm:"column:derecho_de_via"`
	CapacidadVehiculo    *int     `gorm:"column:capacidad_vehiculo"`
	VelocidadPromedioKmh *float64 `gorm:"column:velocidad_promedio_kmh"`
	FrecuenciaMinutos    *float64 `gorm:"column:frecuencia_minutos"`
	Sentido              *int     `gorm:"column:sentido"`
	Fuente               *string  `gorm:"column:fuente"`
}
