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
        await fetchApimetroGeoJson(sistemaParam, signal, nc || undefined);

      map.addSource(SOURCE_LINES, {
        type: "geojson",
        data: linesData,
      });
      map.addSource(SOURCE_STATIONS, {
        type: "geojson",
        data: stationsData,
      });

      addLineLayers(map);
      addPointLayers(map);

      const merged: FeatureCollection = {
        type: "FeatureCollection",
        features: [...stationsData.features, ...linesData.features],
      };
      fitMapToData(map, merged);

      const lineTag =
        nc.length > 0 ? ` · línea comercial: ${nc}` : "";
      setStatus(
        `Red: ${label}${lineTag} · estaciones: ${stationsData.features.length} · líneas (tramos): ${linesData.features.length}`,
      );
    },
    [setStatus, numComercial],
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
  }, [mapReady, sistema, numComercial, loadDataset]);
}
