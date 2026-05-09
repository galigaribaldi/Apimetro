import { apimetroBaseUrl } from "../config";

export function buildGeoJsonQuery(sistema: string): string {
  const p = new URLSearchParams();
  const s = sistema.trim();
  if (s) p.set("sistema", s);
  return p.toString();
}

export function geojsonEstacionUrl(sistema: string): string {
  const base = apimetroBaseUrl();
  const q = buildGeoJsonQuery(sistema);
  return `${base}/movilidad/mapas/geojsonEstacion${q ? `?${q}` : ""}`;
}

/** Same query string as estaciones — extend here when you add shared filters (existe, etc.). */
export function geojsonLineaUrl(sistema: string): string {
  const base = apimetroBaseUrl();
  const q = buildGeoJsonQuery(sistema);
  return `${base}/movilidad/mapas/geojsonLinea${q ? `?${q}` : ""}`;
}
