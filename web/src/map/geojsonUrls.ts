import { apimetroBaseUrl } from "../config";

export type GeoJsonQueryParams = {
  sistema: string;
  /** Commercial line key; only sent when non-empty. */
  numComercial?: string;
};

export function buildGeoJsonQuery(params: GeoJsonQueryParams): string {
  const p = new URLSearchParams();
  const s = params.sistema.trim();
  if (s) p.set("sistema", s);
  const nc = params.numComercial?.trim();
  if (nc) p.set("num_comercial", nc);
  return p.toString();
}

export function geojsonEstacionUrl(
  sistema: string,
  numComercial?: string,
): string {
  const base = apimetroBaseUrl();
  const q = buildGeoJsonQuery({ sistema, numComercial });
  return `${base}/movilidad/mapas/geojsonEstacion${q ? `?${q}` : ""}`;
}

/** Same query string as estaciones — extend here when you add shared filters (existe, etc.). */
export function geojsonLineaUrl(sistema: string, numComercial?: string): string {
  const base = apimetroBaseUrl();
  const q = buildGeoJsonQuery({ sistema, numComercial });
  return `${base}/movilidad/mapas/geojsonLinea${q ? `?${q}` : ""}`;
}
