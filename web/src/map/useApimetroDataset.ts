import { useCallback, useEffect } from "react";
import type maplibregl from "maplibre-gl";
import type { FeatureCollection } from "geojson";
import type { Dispatch, RefObject, SetStateAction } from "react";

import {
  addLineLayers,
  addPointLayers,
  fitMapToData,
  removeTransportLayers,
} from "./apimetroLayers";
import { SISTEMA_OPTIONS, SOURCE_LINES, SOURCE_STATIONS } from "./constants";
import { fetchApimetroGeoJson } from "./geojsonFetch";
import type { MapGeoFilters } from "./geojsonUrls";

function activeFilterSummary(f: MapGeoFilters): string {
  const bits: string[] = [];
  if (f.alcaldiaMunicipio?.trim()) bits.push("alcaldía");
  if (f.nombreRamal?.trim()) bits.push("ramal");
  if (f.jerarquiaTransporte?.trim()) bits.push("jerarquía");
  if (f.derechoDeVia?.trim()) bits.push("derecho de vía");
  if (f.esCetram === "true") bits.push("es_cetram=true");
  if (f.esCetram === "false") bits.push("es_cetram=false");
  if (f.nombreCetram?.trim()) bits.push("nombre_cetram");
  if (f.cetramReal?.trim()) bits.push("cetram_real");
  if (!bits.length) return "";
  return ` · filtros: ${bits.join(", ")}`;
}

export function useApimetroDataset(
  mapRef: RefObject<maplibregl.Map | null>,
  mapReady: boolean,
  filters: MapGeoFilters,
  includeLines: boolean,
  setStatus: Dispatch<SetStateAction<string>>,
) {
  const loadDataset = useCallback(
    async (map: maplibregl.Map, signal: AbortSignal) => {
      const sistemaParam = filters.sistema;
      const label =
        SISTEMA_OPTIONS.find((o) => o.value === sistemaParam)?.label ??
        sistemaParam;
      setStatus(`Loading ${label}…`);
      removeTransportLayers(map);

      const { stations: stationsData, lines: linesData } =
        await fetchApimetroGeoJson(filters, signal, includeLines);

      if (includeLines) {
        map.addSource(SOURCE_LINES, {
          type: "geojson",
          data: linesData,
        });
        addLineLayers(map);
      }

      map.addSource(SOURCE_STATIONS, {
        type: "geojson",
        data: stationsData,
      });

      addPointLayers(map);

      const merged: FeatureCollection = {
        type: "FeatureCollection",
        features: includeLines
          ? [...stationsData.features, ...linesData.features]
          : [...stationsData.features],
      };
      fitMapToData(map, merged);

      const nc = filters.numComercial?.trim() ?? "";
      const lineTag =
        nc.length > 0 ? ` · línea comercial: ${nc}` : "";
      const advTag = activeFilterSummary(filters);
      const tramosTag = includeLines
        ? ` · líneas (tramos): ${linesData.features.length}`
        : " · trazos de línea: no cargados";
      setStatus(
        `Red: ${label}${lineTag}${advTag} · estaciones: ${stationsData.features.length}${tramosTag}`,
      );
    },
    [setStatus, filters, includeLines],
  );

  useEffect(() => {
    if (!mapReady) return;
    const map = mapRef.current;
    if (!map) return;

    const abort = new AbortController();
    loadDataset(map, abort.signal).catch((err: unknown) => {
      if ((err as Error).name === "AbortError") return;
      const msg = err instanceof Error ? err.message : String(err);
      setStatus(`Error: ${msg}`);
    });

    return () => abort.abort();
  }, [mapReady, filters, includeLines, loadDataset]);
}
