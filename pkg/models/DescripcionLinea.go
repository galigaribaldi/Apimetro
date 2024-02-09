package models

type DescripcionLinea struct {
	ID               uint   `gorm:"primary_key" json:"descripcion_linea_id"`
	TerminalOriginal string `json:"terminal_original"`
	InicioOriginal   string `json:"inicio_original"`
	Tipo             string `json:"tipo_linea"`
	Direccion        string `json:"direccion"`
	Descripcion      string `json:"descripcion"`
	Linea            Linea  `gorm:"foreignKey:LineaID;references:ID" json:"-"`
	LineaID          int16  `json:"linea_id"`
}
