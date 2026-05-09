import bbox from "@turf/bbox";
import type maplibregl from "maplibre-gl";
import type { FeatureCollection } from "geojson";

import {
  LAYER_LINE_LABELS,
  LAYER_LINES,
  LAYER_POINT_LABELS,
  LAYER_POINTS,
  SOURCE_LINES,
  SOURCE_STATIONS,
} from "./constants";

export function removeTransportLayers(map: maplibregl.Map): void {
  const layers = [
    LAYER_POINT_LABELS,
    LAYER_LINE_LABELS,
    LAYER_POINTS,
    LAYER_LINES,
  ];
  for (const id of layers) {
    if (map.getLayer(id)) map.removeLayer(id);
  }
  if (map.getSource(SOURCE_STATIONS)) map.removeSource(SOURCE_STATIONS);
  if (map.getSource(SOURCE_LINES)) map.removeSource(SOURCE_LINES);
}

export function fitMapToData(map: maplibregl.Map, data: FeatureCollection): void {
  try {
    const box = bbox(data);
    map.fitBounds(
      [
        [box[0], box[1]],
        [box[2], box[3]],
      ],
      { padding: 56, maxZoom: 14, duration: 600 },
    );
  } catch {
    /* empty or invalid */
  }
}

export function addPointLayers(map: maplibregl.Map): void {
  map.addLayer({
    id: LAYER_POINTS,
    type: "circle",
    source: SOURCE_STATIONS,
    filter: [
      "any",
      ["==", ["geometry-type"], "Point"],
      ["==", ["geometry-type"], "MultiPoint"],
    ],
    paint: {
      "circle-radius": ["interpolate", ["linear"], ["zoom"], 10, 4, 14, 7],
      "circle-color": "#1d4ed8",
      "circle-stroke-width": 1.5,
      "circle-stroke-color": "#ffffff",
    },
  });

  map.addLayer({
    id: LAYER_POINT_LABELS,
    type: "symbol",
    source: SOURCE_STATIONS,
    filter: [
      "any",
      ["==", ["geometry-type"], "Point"],
      ["==", ["geometry-type"], "MultiPoint"],
    ],
    layout: {
      "text-field": ["coalesce", ["get", "nombre"], ""],
      "text-size": [
        "interpolate",
        ["linear"],
        ["zoom"],
        11,
        0,
        12,
        10,
        16,
        11,
      ],
      "text-offset": [0, 1.15],
      "text-anchor": "top",
      "text-font": ["Open Sans Regular", "Arial Unicode MS Regular"],
      "text-max-width": 14,
      "text-optional": true,
    },
    paint: {
      "text-color": "#0f172a",
      "text-halo-color": "#ffffff",
      "text-halo-width": 1.5,
    },
    minzoom: 11,
  });
}

export function addLineLayers(map: maplibregl.Map): void {
  map.addLayer({
    id: LAYER_LINES,
    type: "line",
    source: SOURCE_LINES,
    filter: [
      "any",
      ["==", ["geometry-type"], "LineString"],
      ["==", ["geometry-type"], "MultiLineString"],
    ],
    paint: {
      "line-color": "#64748b",
      "line-width": ["interpolate", ["linear"], ["zoom"], 10, 2, 14, 4],
      "line-opacity": 0.75,
    },
  });

  map.addLayer({
    id: LAYER_LINE_LABELS,
    type: "symbol",
    source: SOURCE_LINES,
    filter: [
      "any",
      ["==", ["geometry-type"], "LineString"],
      ["==", ["geometry-type"], "MultiLineString"],
    ],
    layout: {
      "symbol-placement": "line",
      "text-field": [
        "coalesce",
        ["get", "nombre_ramal"],
        ["get", "nombre_linea"],
        "",
      ],
      "text-size": 10,
      "text-font": ["Open Sans Regular", "Arial Unicode MS Regular"],
      "text-max-angle": 30,
    },
    paint: {
      "text-color": "#334155",
      "text-halo-color": "#ffffff",
      "text-halo-width": 1.2,
    },
    minzoom: 11,
  });
}
