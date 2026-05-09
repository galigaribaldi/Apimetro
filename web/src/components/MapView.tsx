import { useRef, useState } from "react";
import maplibregl from "maplibre-gl";

import "maplibre-gl/dist/maplibre-gl.css";

import { useApimetroDataset } from "../map/useApimetroDataset";
import { useMapFeaturePopup } from "../map/useMapFeaturePopup";
import { useMapInstance } from "../map/useMapInstance";

import { SistemaFilter } from "./SistemaFilter";

export function MapView() {
  const popupRef = useRef<maplibregl.Popup | null>(null);
  const { containerRef, mapRef, mapReady } = useMapInstance(popupRef);
  const [sistema, setSistema] = useState<string>("");
  const [status, setStatus] = useState<string>("");

  useApimetroDataset(mapRef, mapReady, sistema, setStatus);
  useMapFeaturePopup(mapRef, mapReady, sistema, popupRef);

  return (
    <div className="map-layout">
      <aside className="map-sidebar" aria-label="Filtros del mapa">
        <div className="map-sidebar__section">
          <h2 className="map-sidebar__heading">Filtros</h2>
          <SistemaFilter value={sistema} onChange={setSistema} />
          <p className="map-sidebar__hint">
            Misma selección aplica a estaciones y trazos de línea (GeoJSON).
            Acerca el mapa (zoom ≥12) para ver nombres de estaciones con más
            claridad.
          </p>
        </div>
      </aside>

      <div className="map-stage">
        <div
          ref={containerRef}
          className="map-view__canvas"
          role="application"
          aria-label="Mapa interactivo"
        />
        {status ? (
          <p className="map-view__status" role="status">
            {status}
          </p>
        ) : null}
      </div>
    </div>
  );
}
