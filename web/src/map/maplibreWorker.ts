import maplibregl from "maplibre-gl";
import workerUrl from "maplibre-gl/dist/maplibre-gl-csp-worker.js?url";

/** CSP worker URL for bundlers; runtime API exists but typings vary by maplibre-gl version. */
(maplibregl as unknown as { workerUrl: string }).workerUrl = workerUrl;
