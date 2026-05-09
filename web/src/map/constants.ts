/** Values match GeoJSON `sistema` query (Swagger). Empty = omit param → all systems. */
export const SISTEMA_OPTIONS = [
  { value: "", label: "Todos (todas las redes)" },
  { value: "METRO", label: "METRO" },
  { value: "MB", label: "MB (Metrobús)" },
  { value: "CBB", label: "CBB (Cablebús)" },
  { value: "RTP", label: "RTP" },
  { value: "TROLE", label: "TROLE" },
  { value: "TL", label: "TL (Tren ligero)" },
  { value: "MEXIBUS", label: "MEXIBUS" },
  { value: "MEXICABLE", label: "MEXICABLE" },
  { value: "INTERURBANO", label: "INTERURBANO" },
  { value: "CC", label: "CC (Cable Car)" },
] as const;

export const SOURCE_STATIONS = "apimetro-data";
export const SOURCE_LINES = "apimetro-lines-data";

export const LAYER_POINTS = "apimetro-points";
export const LAYER_POINT_LABELS = "apimetro-point-labels";
export const LAYER_LINES = "apimetro-lines";
export const LAYER_LINE_LABELS = "apimetro-line-labels";

export const CLICKABLE_LAYERS = [
  LAYER_POINTS,
  LAYER_LINES,
  LAYER_POINT_LABELS,
  LAYER_LINE_LABELS,
] as const;
