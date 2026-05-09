import "./maplibreWorker";
import { useEffect, useRef, useState } from "react";
import type { RefObject } from "react";
import maplibregl from "maplibre-gl";

import { BASEMAP_STYLE } from "./basemapStyle";

export function useMapInstance(popupRef: RefObject<maplibregl.Popup | null>) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<maplibregl.Map | null>(null);
  const [mapReady, setMapReady] = useState(false);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;

    const map = new maplibregl.Map({
      container: el,
      style: BASEMAP_STYLE,
      center: [-99.1332, 19.4326],
      zoom: 11,
    });

    map.addControl(new maplibregl.NavigationControl(), "top-right");
    map.addControl(
      new maplibregl.AttributionControl({ compact: true }),
      "bottom-right",
    );
    mapRef.current = map;

    const onLoad = () => setMapReady(true);
    map.once("load", onLoad);

    return () => {
      map.off("load", onLoad);
      setMapReady(false);
      popupRef.current?.remove();
      popupRef.current = null;
      map.remove();
      mapRef.current = null;
    };
  }, [popupRef]);

  return { containerRef, mapRef, mapReady };
}
