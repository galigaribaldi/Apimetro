import { useEffect, useState } from "react";

import { fetchNumComercialOptions } from "./lineaCatalog";

export type NumComercialOption = { value: string; label: string };

export function useNumComercialOptions(sistema: string) {
  const [options, setOptions] = useState<NumComercialOption[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const s = sistema.trim();
    if (!s) {
      setOptions([]);
      setError(null);
      setLoading(false);
      return;
    }

    const ac = new AbortController();
    let active = true;
    setLoading(true);
    setError(null);

    fetchNumComercialOptions(s, ac.signal)
      .then((opts) => {
        if (active) setOptions(opts);
      })
      .catch((err: unknown) => {
        if (!active) return;
        if ((err as Error).name === "AbortError") return;
        setOptions([]);
        setError(err instanceof Error ? err.message : String(err));
      })
      .finally(() => {
        if (active) setLoading(false);
      });

    return () => {
      active = false;
      ac.abort();
    };
  }, [sistema]);

  return { options, loading, error };
}
