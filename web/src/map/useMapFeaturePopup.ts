import { useEffect } from "react";
import maplibregl from "maplibre-gl";
import type { RefObject } from "react";

import { CLICKABLE_LAYERS } from "./constants";
import { formatFeaturePopup } from "./popupHtml";

export function useMapFeaturePopup(
  mapRef: RefObject<maplibregl.Map | null>,
  mapReady: boolean,
  sistema: string,
  popupRef: RefObject<maplibregl.Popup | null>,
) {
  useEffect(() => {
    if (!mapReady || !mapRef.current) return;
    const map = mapRef.current;

    const clickableLayers = (): string[] =>
      CLICKABLE_LAYERS.filter((id) => map.getLayer(id));

    const onClick = (e: maplibregl.MapMouseEvent) => {
      const layers = clickableLayers();
      const feats =
        layers.length > 0
          ? map.queryRenderedFeatures(e.point, { layers })
          : [];

      const f = feats[0];
      if (!f?.properties || Object.keys(f.properties).length === 0) {
        popupRef.current?.remove();
        popupRef.current = null;
        return;
      }

      popupRef.current?.remove();
      popupRef.current = new maplibregl.Popup({
        maxWidth: "min(360px, 92vw)",
        closeButton: true,
      })
        .setLngLat(e.lngLat)
        .setHTML(
          formatFeaturePopup(f.properties as Record<string, unknown>),
        )
        .addTo(map);
    };

    map.on("click", onClick);
    return () => {
      map.off("click", onClick);
      popupRef.current?.remove();
      popupRef.current = null;
    };
  }, [mapReady, sistema, mapRef, popupRef]);
}
