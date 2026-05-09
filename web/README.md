# Apimetro — Web (map UI)

Single-page app for exploring public transport data on a map. Built with **Vite**, **React**, **TypeScript**, and **MapLibre GL**.

## Requirements

- **Node.js** 20+ and npm
- A running **Apimetro API** (the UI talks to it over HTTP)

## Install and run locally

```bash
cd web
npm install
npm run dev
```

Open the URL Vite prints (for example `http://localhost:5173`).

## Configuring the API URL

| Scenario | What to do |
|----------|------------|
| **Local dev with proxy** | Leave `VITE_APIMETRO_BASE_URL` unset. The dev server proxies `/movilidad` to `http://localhost:8080` (see `vite.config.ts`). Start the API separately (for example with Docker). |
| **Fixed API origin** | Copy `.env.example` to `.env` and set `VITE_APIMETRO_BASE_URL` to that origin (no trailing slash). |
| **Same domain as the API in production** | Usually leave `VITE_APIMETRO_BASE_URL` empty so the browser calls `/movilidad/...` on the current host. Serve `dist/` from your reverse proxy next to the API routes. |

## Production build

```bash
npm run build
```

Static output is written to **`dist/`**. Deploy those files behind your web server or CDN and route API traffic to the Go service as you do for the rest of Apimetro.

## Customization (optional)

- **Basemap / style:** `src/map/basemapStyle.ts` (default uses OpenStreetMap raster tiles; no third-party map API key required for that path).
- **Theme:** The app uses the same `data-theme` + `localStorage` key as the main Apimetro landing page, so light/dark preference can stay in sync when both are on the same site.

## Development notes

- **Header links** (`/docs`, `/swagger/...`) only work in dev if your environment serves them (for example by running the full API stack or proxying those paths). On a combined production deploy they typically work like the main site.
