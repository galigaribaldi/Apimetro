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

export function useApimetroDataset(
  mapRef: RefObject<maplibregl.Map | null>,
  mapReady: boolean,
  sistema: string,
  numComercial: string,
  includeLines: boolean,
  setStatus: Dispatch<SetStateAction<string>>,
) {
  const loadDataset = useCallback(
    async (map: maplibregl.Map, sistemaParam: string, signal: AbortSignal) => {
      const label =
        SISTEMA_OPTIONS.find((o) => o.value === sistemaParam)?.label ??
        sistemaParam;
      setStatus(`Loading ${label}…`);
      removeTransportLayers(map);

      const nc = numComercial.trim();
      const { stations: stationsData, lines: linesData } =
        await fetchApimetroGeoJson(
          sistemaParam,
          signal,
          nc || undefined,
          includeLines,
        );

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

      const lineTag =
        nc.length > 0 ? ` · línea comercial: ${nc}` : "";
      const tramosTag = includeLines
        ? ` · líneas (tramos): ${linesData.features.length}`
        : " · trazos de línea: no cargados";
      setStatus(
        `Red: ${label}${lineTag} · estaciones: ${stationsData.features.length}${tramosTag}`,
      );
    },
    [setStatus, numComercial, includeLines],
  );

  useEffect(() => {
    if (!mapReady) return;
    const map = mapRef.current;
    if (!map) return;

    const abort = new AbortController();
    loadDataset(map, sistema, abort.signal).catch((err: unknown) => {
      if ((err as Error).name === "AbortError") return;
      const msg = err instanceof Error ? err.message : String(err);
      setStatus(`Error: ${msg}`);
    });

    return () => abort.abort();
  }, [mapReady, sistema, numComercial, includeLines, loadDataset]);
}
