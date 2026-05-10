import { useRef, useState } from "react";
import maplibregl from "maplibre-gl";

import "maplibre-gl/dist/maplibre-gl.css";

import { useApimetroDataset } from "../map/useApimetroDataset";
import { useMapFeaturePopup } from "../map/useMapFeaturePopup";
import { useMapInstance } from "../map/useMapInstance";
import { useNumComercialOptions } from "../map/useNumComercialOptions";

import { NumComercialFilter } from "./NumComercialFilter";
import { SistemaFilter } from "./SistemaFilter";

export function MapView() {
  const popupRef = useRef<maplibregl.Popup | null>(null);
  const { containerRef, mapRef, mapReady } = useMapInstance(popupRef);
  const [sistema, setSistema] = useState<string>("");
  const [numComercial, setNumComercial] = useState<string>("");
  const [showLineTrazos, setShowLineTrazos] = useState(true);
  const [status, setStatus] = useState<string>("");

  const lineaOptions = useNumComercialOptions(sistema);
  const showLineFilter = sistema.trim().length > 0;

  useApimetroDataset(
    mapRef,
    mapReady,
    sistema,
    numComercial,
    showLineTrazos,
    setStatus,
  );
  useMapFeaturePopup(mapRef, mapReady, sistema, popupRef);

  const handleSistemaChange = (value: string) => {
    setSistema(value);
    setNumComercial("");
  };

  return (
    <div className="map-layout">
      <aside className="map-sidebar" aria-label="Filtros del mapa">
        <div className="map-sidebar__section">
          <h2 className="map-sidebar__heading">Filtros</h2>
          <SistemaFilter value={sistema} onChange={handleSistemaChange} />
          {showLineFilter ? (
            <NumComercialFilter
              value={numComercial}
              onChange={setNumComercial}
              options={lineaOptions.options}
              loading={lineaOptions.loading}
              error={lineaOptions.error}
            />
          ) : null}
          <div className="map-field map-field--checkbox">
            <label htmlFor="show-line-trazos">
              <input
                id="show-line-trazos"
                type="checkbox"
                checked={showLineTrazos}
                onChange={(e) => setShowLineTrazos(e.target.checked)}
              />
              Mostrar trazos de línea{" "}
              <span className="map-field__hint-inline">
                (GET geojsonLinea; más datos)
              </span>
            </label>
          </div>
          <p className="map-sidebar__hint">
            El filtro de red y línea comercial aplica a las estaciones. Si
            activas trazos, la misma selección filtra también{" "}
            <code className="map-inline-code">geojsonLinea</code>. Acerca el
            mapa (zoom ≥12) para ver nombres con más claridad.
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
