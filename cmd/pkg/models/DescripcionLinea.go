package models

type DescripcionLinea struct {
	ID                     uint   `gorm:"primary_key" json:"descripcion_linea_id" example:"1"`
	Terminal_original      string `json:"terminal_original" example:"Observatorio"`
	Inicio_original        string `json:"inicio_original" example:"1969"`
	Tipo                   string `json:"tipo_linea" example:"Metropolitana"`
	Direccion              string `json:"direccion" example:"Oriente-Poniente"`
	Descripcion            string `json:"descripcion" example:"Línea que conecta Observatorio con Pantitlán cruzando el centro histórico"`
	Anio_inicio_ampliacion uint   `json:"anio_inicio_ampliacion" example:"1984"`
	Anio_fin_ampliacion    uint   `json:"anio_fin_ampliacion" example:"1986"`
	Linea                  Linea  `gorm:"foreignKey:Linea_base;references:ID" json:"-"`
	Linea_base             uint   `json:"linea_base" example:"1"`
}
