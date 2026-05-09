import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      // Same-origin requests in dev: leave VITE_APIMETRO_BASE_URL unset and call /movilidad/...
      "/movilidad": {
        target: "http://localhost:8080",
        changeOrigin: true,
      },
    },
  },
});
