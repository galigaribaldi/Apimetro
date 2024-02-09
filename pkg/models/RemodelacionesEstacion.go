package models

type RemodelacionesEstacion struct {
	ID                      int                 `gorm:"primary_key" json:"remodelacion_estacion_id"`
	CausaRemodelacion       string              `json:"nombre"`
	DescripcionRemodelacion string              `json:"descripcion_remodelacion_estacion"`
	FechaInicio             string              `json:"fecha_inicio"`
	FechaFin                int                 `json:"fecha_fin"`
	DescripcionEstacion     DescripcionEstacion `gorm:"foreignKey:DescripcionEstacionID;references:ID" json:"-"`
	DescripcionEstacionID   int16               `json:"descripcion_estacion_id"`
}
