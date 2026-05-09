/** Base URL for the Apimetro API (no trailing slash). Empty = same origin (use Vite proxy in dev). */
export function apimetroBaseUrl(): string {
  const raw = import.meta.env.VITE_APIMETRO_BASE_URL as string | undefined;
  return (raw ?? "").replace(/\/+$/, "");
}
