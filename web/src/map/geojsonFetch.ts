import type { FeatureCollection } from "geojson";

import {
  type MapGeoFilters,
  geojsonEstacionUrl,
  geojsonLineaUrl,
} from "./geojsonUrls";

export type ApimetroGeoJsonBundle = {
  stations: FeatureCollection;
  lines: FeatureCollection;
};

export async function fetchApimetroGeoJson(
  filters: MapGeoFilters,
  signal: AbortSignal,
  includeLines = true,
): Promise<ApimetroGeoJsonBundle> {
  const stationsUrl = geojsonEstacionUrl(filters);

  if (!includeLines) {
    const stationsRes = await fetch(stationsUrl, { signal });
    if (!stationsRes.ok) {
      throw new Error(
        `${stationsRes.status} ${stationsRes.statusText} — ${stationsUrl}`,
      );
    }
    const stations = (await stationsRes.json()) as FeatureCollection;
    return {
      stations,
      lines: { type: "FeatureCollection", features: [] },
    };
  }

  const linesUrl = geojsonLineaUrl(filters);

  const [stationsRes, linesRes] = await Promise.all([
    fetch(stationsUrl, { signal }),
    fetch(linesUrl, { signal }),
  ]);

  if (!stationsRes.ok) {
    throw new Error(
      `${stationsRes.status} ${stationsRes.statusText} — ${stationsUrl}`,
    );
  }
  if (!linesRes.ok) {
    throw new Error(`${linesRes.status} ${linesRes.statusText} — ${linesUrl}`);
  }

  const stations = (await stationsRes.json()) as FeatureCollection;
  const lines = (await linesRes.json()) as FeatureCollection;

  return { stations, lines };
}
