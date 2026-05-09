/** Minimal escaping for text shown in HTML popups (GeoJSON properties). */
function escapeHtml(s: string): string {
  return s
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function row(label: string, value: unknown): string {
  if (value === null || value === undefined || value === "") return "";
  const str =
    typeof value === "object" ? JSON.stringify(value) : String(value);
  return `<div class="map-popup__row"><span class="map-popup__k">${escapeHtml(label)}</span> <span class="map-popup__v">${escapeHtml(str)}</span></div>`;
}

/** Build popup HTML from GeoJSON feature properties (station / line / polygon). */
export function formatFeaturePopup(props: Record<string, unknown>): string {
  const tipo =
    typeof props.tipo_entidad === "string" ? props.tipo_entidad : "";

  const blocks: string[] = [];

  if (tipo === "estacion" || props.nombre) {
    blocks.push(
      row("Nombre", props.nombre),
      row("Sistema", props.sistema),
      row("Tipo", props.tipo),
      row("Alcaldía / municipio", props.alcaldia_municipio),
      row("Jerarquía", props.jerarquia_transporte),
      row("CETRAM", props.es_cetram),
      row("Nombre CETRAM", props.nombre_cetram),
    );
  } else if (tipo === "ruta" || props.nombre_linea || props.nombre_ramal) {
    blocks.push(
      row("Línea", props.nombre_linea),
      row("Ramal", props.nombre_ramal),
      row("Sistema", props.sistema),
      row("Color", props.color_esp),
      row("Sentido", props.sentido),
      row("Vel. prom. (km/h)", props.velocidad_promedio_kmh),
      row("Frecuencia (min)", props.frecuencia_minutos),
      row("Distancia (m)", props.distancia_metros),
    );
  } else if (tipo === "poligono_administrativo" || props.cvegeo) {
    blocks.push(
      row("Nombre", props.nombre),
      row("Entidad", props.entidad),
      row("Nivel", props.nivel),
      row("CVEGEO", props.cvegeo),
    );
  } else {
    for (const [k, v] of Object.entries(props)) {
      if (k === "tipo_entidad") continue;
      blocks.push(row(k, v));
    }
  }

  const inner = blocks.filter(Boolean).join("") || row("Detalle", "(sin datos)");

  return `<div class="map-popup">${inner}</div>`;
}
