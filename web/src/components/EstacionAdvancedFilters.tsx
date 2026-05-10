type Props = {
  onClearAdvanced: () => void;
  alcaldiaMunicipio: string;
  onAlcaldiaMunicipioChange: (v: string) => void;
  nombreRamal: string;
  onNombreRamalChange: (v: string) => void;
  jerarquiaTransporte: string;
  onJerarquiaTransporteChange: (v: string) => void;
  derechoDeVia: string;
  onDerechoDeViaChange: (v: string) => void;
  nombreCetram: string;
  onNombreCetramChange: (v: string) => void;
  cetramReal: string;
  onCetramRealChange: (v: string) => void;
  esCetramTrue: boolean;
  esCetramFalse: boolean;
  onEsCetramTrueChange: (v: boolean) => void;
  onEsCetramFalseChange: (v: boolean) => void;
};

export function EstacionAdvancedFilters({
  onClearAdvanced,
  alcaldiaMunicipio,
  onAlcaldiaMunicipioChange,
  nombreRamal,
  onNombreRamalChange,
  jerarquiaTransporte,
  onJerarquiaTransporteChange,
  derechoDeVia,
  onDerechoDeViaChange,
  nombreCetram,
  onNombreCetramChange,
  cetramReal,
  onCetramRealChange,
  esCetramTrue,
  esCetramFalse,
  onEsCetramTrueChange,
  onEsCetramFalseChange,
}: Props) {
  const hasAdvancedFilters =
    Boolean(alcaldiaMunicipio.trim()) ||
    Boolean(nombreRamal.trim()) ||
    Boolean(jerarquiaTransporte.trim()) ||
    Boolean(derechoDeVia.trim()) ||
    Boolean(nombreCetram.trim()) ||
    Boolean(cetramReal.trim()) ||
    esCetramTrue ||
    esCetramFalse;

  return (
    <details className="map-advanced-details">
      <summary className="map-advanced-details__summary">
        Filtros avanzados (API{" "}
        <code className="map-inline-code">geojsonEstacion</code>)
      </summary>
      <div className="map-advanced-details__body">
        <button
          type="button"
          className="map-advanced-clear"
          disabled={!hasAdvancedFilters}
          onClick={onClearAdvanced}
        >
          Limpiar filtros avanzados
        </button>
        <div className="map-field">
          <label htmlFor="filter-alcaldia">Alcaldía / municipio</label>
          <input
            id="filter-alcaldia"
            className="map-view__input"
            type="text"
            autoComplete="off"
            placeholder="ej. Iztapalapa"
            value={alcaldiaMunicipio}
            onChange={(e) => onAlcaldiaMunicipioChange(e.target.value)}
          />
        </div>
        <div className="map-field">
          <label htmlFor="filter-ramal">Nombre ramal</label>
          <input
            id="filter-ramal"
            className="map-view__input"
            type="text"
            autoComplete="off"
            value={nombreRamal}
            onChange={(e) => onNombreRamalChange(e.target.value)}
          />
        </div>
        <div className="map-field">
          <label htmlFor="filter-jerarquia">Jerarquía transporte</label>
          <input
            id="filter-jerarquia"
            className="map-view__input"
            type="text"
            autoComplete="off"
            value={jerarquiaTransporte}
            onChange={(e) => onJerarquiaTransporteChange(e.target.value)}
          />
        </div>
        <div className="map-field">
          <label htmlFor="filter-dv">Derecho de vía</label>
          <input
            id="filter-dv"
            className="map-view__input"
            type="text"
            autoComplete="off"
            placeholder="Superficie, Elevado, Subterráneo"
            value={derechoDeVia}
            onChange={(e) => onDerechoDeViaChange(e.target.value)}
          />
        </div>
        <div className="map-field">
          <label htmlFor="filter-nombre-cetram">Nombre CETRAM</label>
          <input
            id="filter-nombre-cetram"
            className="map-view__input"
            type="text"
            autoComplete="off"
            value={nombreCetram}
            onChange={(e) => onNombreCetramChange(e.target.value)}
          />
        </div>
        <div className="map-field">
          <label htmlFor="filter-cetram-real">CETRAM real (radio ~250 m)</label>
          <input
            id="filter-cetram-real"
            className="map-view__input"
            type="text"
            autoComplete="off"
            value={cetramReal}
            onChange={(e) => onCetramRealChange(e.target.value)}
          />
        </div>
        <fieldset className="map-fieldset">
          <legend className="map-fieldset__legend">es_cetram</legend>
          <div className="map-field map-field--checkbox">
            <label htmlFor="filter-es-cetram-true">
              <input
                id="filter-es-cetram-true"
                type="checkbox"
                checked={esCetramTrue}
                onChange={(e) => {
                  onEsCetramTrueChange(e.target.checked);
                  if (e.target.checked) onEsCetramFalseChange(false);
                }}
              />
              true (solo con CETRAM)
            </label>
          </div>
          <div className="map-field map-field--checkbox">
            <label htmlFor="filter-es-cetram-false">
              <input
                id="filter-es-cetram-false"
                type="checkbox"
                checked={esCetramFalse}
                onChange={(e) => {
                  onEsCetramFalseChange(e.target.checked);
                  if (e.target.checked) onEsCetramTrueChange(false);
                }}
              />
              false (sin CETRAM)
            </label>
          </div>
          <p className="map-sidebar__hint map-fieldset__hint">
            Marca solo uno, o ninguno para no enviar el parámetro.
          </p>
        </fieldset>
      </div>
    </details>
  );
}
