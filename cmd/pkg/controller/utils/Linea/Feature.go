package utils

type GeoJSONFeature struct {
	Type       string                 `json:"type"` // always "Feature"
	Geometry   Geometry               `json:"geometry"`
	Properties map[string]interface{} `json:"properties"`
}

type Geometry struct {
	Type        string      `json:"type"` // "MultiLineString"
	Coordinates interface{} `json:"coordinates"`
}

type FeatureCollection struct {
	Type     string           `json:"type"` // always "FeatureCollection"
	Features []GeoJSONFeature `json:"features"`
}
