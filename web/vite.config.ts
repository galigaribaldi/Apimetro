import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

// https://vite.dev/config/
export default defineConfig(({ mode }) => ({
  // Production build lands in ../cmd/pkg/routes/static/map (go:embed); asset URLs must be under /static/map/
  base: mode === "production" ? "/static/map/" : "/",
  plugins: [react()],
  build: {
    outDir: "../cmd/pkg/routes/static/map",
    emptyOutDir: true,
  },
  server: {
    proxy: {
      // Same-origin requests in dev: leave VITE_APIMETRO_BASE_URL unset and call /movilidad/...
      "/movilidad": {
        target: "http://localhost:8080",
        changeOrigin: true,
      },
    },
  },
}));
