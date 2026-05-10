import { apimetroBaseUrl } from "../config";

type LineaListRow = {
  num_comercial?: string;
  nombre?: string;
};

/**
 * Today we call `GET /movilidad/{sistema}/linea` only to populate the map’s
 * `num_comercial` dropdown. That endpoint returns full line records (ramales,
 * geometry pointers, nested relations, etc.). Prefer a dedicated lightweight
 * route (e.g. distinct `num_comercial` + display label) once the API exposes it,
 * so we do not download fields the UI never uses.
 */
export async function fetchNumComercialOptions(
  sistema: string,
  signal: AbortSignal,
): Promise<{ value: string; label: string }[]> {
  const base = apimetroBaseUrl();
  const url = `${base}/movilidad/${encodeURIComponent(sistema)}/linea`;
  const res = await fetch(url, { signal });
  if (!res.ok) {
    throw new Error(`${res.status} ${res.statusText} — ${url}`);
  }
  const rows = (await res.json()) as LineaListRow[];

  const byNum = new Map<string, string>();
  for (const row of rows) {
    const v = row.num_comercial?.trim();
    if (!v || byNum.has(v)) continue;
    const name = typeof row.nombre === "string" ? row.nombre.trim() : "";
    byNum.set(v, name ? `${v} — ${name}` : v);
  }

  return [...byNum.entries()]
    .map(([value, label]) => ({ value, label }))
    .sort((a, b) => a.label.localeCompare(b.label, "es"));
}
