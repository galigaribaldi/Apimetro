import { useCallback, useMemo, useRef, useState } from "react";
import maplibregl from "maplibre-gl";

import "maplibre-gl/dist/maplibre-gl.css";

import type { MapGeoFilters } from "../map/geojsonUrls";
import { useApimetroDataset } from "../map/useApimetroDataset";
import { useMapFeaturePopup } from "../map/useMapFeaturePopup";
import { useMapInstance } from "../map/useMapInstance";
import { useNumComercialOptions } from "../map/useNumComercialOptions";

import { EstacionAdvancedFilters } from "./EstacionAdvancedFilters";
import { NumComercialFilter } from "./NumComercialFilter";
import { SistemaFilter } from "./SistemaFilter";

export function MapView() {
  const popupRef = useRef<maplibregl.Popup | null>(null);
  const { containerRef, mapRef, mapReady } = useMapInstance(popupRef);
  const [sistema, setSistema] = useState<string>("");
  const [numComercial, setNumComercial] = useState<string>("");
  const [showLineTrazos, setShowLineTrazos] = useState(true);
  const [status, setStatus] = useState<string>("");

  const [alcaldiaMunicipio, setAlcaldiaMunicipio] = useState("");
  const [nombreRamal, setNombreRamal] = useState("");
  const [jerarquiaTransporte, setJerarquiaTransporte] = useState("");
  const [derechoDeVia, setDerechoDeVia] = useState("");
  const [nombreCetram, setNombreCetram] = useState("");
  const [cetramReal, setCetramReal] = useState("");
  const [esCetramTrue, setEsCetramTrue] = useState(false);
  const [esCetramFalse, setEsCetramFalse] = useState(false);

  const geoFilters = useMemo<MapGeoFilters>(() => {
    const nc = numComercial.trim();
    return {
      sistema,
      numComercial: nc || undefined,
      alcaldiaMunicipio: alcaldiaMunicipio.trim() || undefined,
      nombreRamal: nombreRamal.trim() || undefined,
      jerarquiaTransporte: jerarquiaTransporte.trim() || undefined,
      derechoDeVia: derechoDeVia.trim() || undefined,
      nombreCetram: nombreCetram.trim() || undefined,
      cetramReal: cetramReal.trim() || undefined,
      esCetram: esCetramTrue ? "true" : esCetramFalse ? "false" : undefined,
    };
  }, [
    sistema,
    numComercial,
    alcaldiaMunicipio,
    nombreRamal,
    jerarquiaTransporte,
    derechoDeVia,
    nombreCetram,
    cetramReal,
    esCetramTrue,
    esCetramFalse,
  ]);

  const lineaOptions = useNumComercialOptions(sistema);
  const showSystemFilters = sistema.trim().length > 0;

  useApimetroDataset(mapRef, mapReady, geoFilters, showLineTrazos, setStatus);
  useMapFeaturePopup(mapRef, mapReady, sistema, popupRef);

  const resetAdvancedFilters = useCallback(() => {
    setAlcaldiaMunicipio("");
    setNombreRamal("");
    setJerarquiaTransporte("");
    setDerechoDeVia("");
    setNombreCetram("");
    setCetramReal("");
    setEsCetramTrue(false);
    setEsCetramFalse(false);
  }, []);

  const handleSistemaChange = (value: string) => {
    setSistema(value);
    setNumComercial("");
    resetAdvancedFilters();
  };

  return (
    <div className="map-layout">
      <aside className="map-sidebar" aria-label="Filtros del mapa">
        <div className="map-sidebar__section">
          <h2 className="map-sidebar__heading">Filtros</h2>
          <SistemaFilter value={sistema} onChange={handleSistemaChange} />
          {showSystemFilters ? (
            <NumComercialFilter
              value={numComercial}
              onChange={setNumComercial}
              options={lineaOptions.options}
              loading={lineaOptions.loading}
              error={lineaOptions.error}
            />
          ) : null}
          <EstacionAdvancedFilters
            onClearAdvanced={resetAdvancedFilters}
            alcaldiaMunicipio={alcaldiaMunicipio}
            onAlcaldiaMunicipioChange={setAlcaldiaMunicipio}
            nombreRamal={nombreRamal}
            onNombreRamalChange={setNombreRamal}
            jerarquiaTransporte={jerarquiaTransporte}
            onJerarquiaTransporteChange={setJerarquiaTransporte}
            derechoDeVia={derechoDeVia}
            onDerechoDeViaChange={setDerechoDeVia}
            nombreCetram={nombreCetram}
            onNombreCetramChange={setNombreCetram}
            cetramReal={cetramReal}
            onCetramRealChange={setCetramReal}
            esCetramTrue={esCetramTrue}
            esCetramFalse={esCetramFalse}
            onEsCetramTrueChange={setEsCetramTrue}
            onEsCetramFalseChange={setEsCetramFalse}
          />
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
            Se envían los mismos parámetros de consulta a{" "}
            <code className="map-inline-code">geojsonEstacion</code> y a{" "}
            <code className="map-inline-code">geojsonLinea</code> si muestras
            trazos; el backend de líneas solo aplica parte de ellos (p. ej.
            alcaldía o <code className="map-inline-code">nombre_cetram</code> no
            filtran trazos en el servidor). Sin red, el API usa todas las redes.
            El número comercial solo aparece al elegir una red. Acerca el mapa
            (zoom ≥12) para ver nombres con más claridad.
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
