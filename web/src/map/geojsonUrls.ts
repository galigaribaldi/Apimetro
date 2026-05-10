import { apimetroBaseUrl } from "../config";

/** Shared UI → API mapping for GeoJSON map layers (we send the same query string to both routes; the líneas API only honors a subset). */
export type MapGeoFilters = {
  sistema: string;
  numComercial?: string;
  alcaldiaMunicipio?: string;
  nombreRamal?: string;
  jerarquiaTransporte?: string;
  derechoDeVia?: string;
  /** Sent as query string `true` / `false`; omit when undefined. */
  esCetram?: "true" | "false";
  nombreCetram?: string;
  cetramReal?: string;
};

function setIf(p: URLSearchParams, key: string, value: string | undefined): void {
  const v = value?.trim();
  if (v) p.set(key, v);
}

/** One query string for both map GeoJSON URLs (extra keys on `geojsonLinea` may be ignored server-side). */
export function buildMapGeoJsonQuery(f: MapGeoFilters): string {
  const p = new URLSearchParams();
  const s = f.sistema.trim();
  if (s) p.set("sistema", s);
  setIf(p, "num_comercial", f.numComercial);
  setIf(p, "alcaldia_municipio", f.alcaldiaMunicipio);
  setIf(p, "nombre_ramal", f.nombreRamal);
  setIf(p, "jerarquia_transporte", f.jerarquiaTransporte);
  setIf(p, "derecho_de_via", f.derechoDeVia);
  if (f.esCetram === "true" || f.esCetram === "false") {
    p.set("es_cetram", f.esCetram);
  }
  setIf(p, "nombre_cetram", f.nombreCetram);
  setIf(p, "cetram_real", f.cetramReal);
  return p.toString();
}

export function geojsonEstacionUrl(filters: MapGeoFilters): string {
  const base = apimetroBaseUrl();
  const q = buildMapGeoJsonQuery(filters);
  return `${base}/movilidad/mapas/geojsonEstacion${q ? `?${q}` : ""}`;
}

export function geojsonLineaUrl(filters: MapGeoFilters): string {
  const base = apimetroBaseUrl();
  const q = buildMapGeoJsonQuery(filters);
  return `${base}/movilidad/mapas/geojsonLinea${q ? `?${q}` : ""}`;
}
