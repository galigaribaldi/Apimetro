package models

type Linea struct {
	ID      uint   `json: "id" 	gorm: "primary_key"`
	Numero  string `json: "numero"`
	Sistema string `json: "sistema"`
	Anio    string `json: "anio"`
	Color   string `json: "color"`
}
