package models

type RemodelacionesLinea struct {
	ID                      int              `gorm:"primary_key" json:"remodelacion_estacion_id"`
	CausaRemodelacion       string           `json:"nombre"`
	DescripcionRemodelacion string           `json:"descripcion_remodelacion_linea"`
	FechaInicio             string           `json:"fecha_inicio"`
	FechaFin                int              `json:"fecha_fin"`
	DescripcionLinea        DescripcionLinea `gorm:"foreignKey:DescripcionLineaID;references:ID" json:"-"`
	DescripcionLineaID      int16            `json:"descripcion_linea_id"`
}
