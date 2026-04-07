package models

import "time"

// HistoricoOperacion mapea la tabla historico_operacion de la BD
// Puntero por si aplica a toda la línea y no a un ramal específico
type HistoricoOperacion struct {
	ID                   int       `gorm:"primary_key" json:"id"`
	LineaID              int       `gorm:"column:linea_id" json:"linea_id"`
	RamalID              int       `gorm:"column:ramal_id;unique" json:"ramal_id"`
	VelocidadPromedioKmh *float64  `gorm:"column:velocidad_promedio_kmh" json:"velocidad_promedio_kmh"`
	FrecuenciaMinutos    *float64  `gorm:"column:frecuencia_minutos" json:"frecuencia_minutos"`
	Fuente               *string   `gorm:"column:fuente" json:"fuente"`
	FechaRegistro        time.Time `gorm:"column:fecha_registro;default:CURRENT_TIMESTAMP" json:"fecha_registro"`
}
