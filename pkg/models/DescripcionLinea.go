package models

type DescripcionLinea struct {
	ID                		uint   `gorm:"primary_key" json:"descripcion_linea_id"`
	Terminal_original 		string `json:"terminal_original"`
	Inicio_original   		string `json:"inicio_original"`
	Tipo              		string `json:"tipo_linea"`
	Direccion         		string `json:"direccion"`
	Descripcion       		string `json:"descripcion"`
	Anio_inicio_ampliacion 	uint   `json:"anio_inicio_ampliacion"`
	Anio_fin_ampliacion 	uint   `json:"anio_fin_ampliacion"`	
	Linea_base        		int    `json:"linea_base"`
}
