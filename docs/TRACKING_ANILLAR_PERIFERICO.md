# Tracking — Propuesta Anillo Periférico Interior

**Rama:** `feat/propuesta-anillar`
**Fecha inicio:** 2026-09-16
**Relacionado:** `docs/NOTAS_REPLICABILIDAD_PROPUESTA.md` (requisitos VFTModel)

---

## Objetivo

Entregar 2 entornos Docker aislados con la red actual de transporte + 4 líneas del Anillo Periférico Interior, uno modelado como MB (BRT) y otro como METRO, para que VFTModel ejecute sus 6 indicadores topológicos comparativos.

---

## Ruta completa de trabajo

### Fase 0 — Datos limpios y estaciones puente

| Paso | Estado | Descripción |
|------|--------|-------------|
| 0.1 Extracción de datos fuente | COMPLETADO | Datos de `ETL/Backups/estacions_Back.csv` y `lineas_Back.csv`, líneas 71-74 |
| 0.2 Corrección de alcaldías | COMPLETADO | Reverse geocoding por coordenadas. Corregidas 89 estaciones (Ecatepec→Álvaro Obregón, Nezahualcóyotl→Miguel Hidalgo, etc.) |
| 0.3 Normalización estado_ciudad | COMPLETADO | `CDCapital` → `CDMX`/`EDOMEX` según ubicación real |
| 0.4 Análisis de conectividad | COMPLETADO | 2 gaps detectados: L72→L73 (1.7km), L74→L71 (3.0km) |
| 0.5 Creación estaciones puente | COMPLETADO | Última estación de cada línea = primera de la siguiente (coords idénticas) |
| 0.6 Cierre gap L74→L71 | COMPLETADO | 4 estaciones intermedias: Estrella del Sur, Culhuacán, Atlalilco/Periférico, Canal de Chalco/Periférico |
| 0.7 Cierre gap L72→L73 | COMPLETADO | 1 estación intermedia: Torres de Satélite |
| 0.8 Generación CSV maestro | COMPLETADO | `ETL/Data/Anillar/estaciones_periferico_interior.csv` — 98 estaciones, 4 líneas |
| 0.9 Verificación de conexiones | COMPLETADO | 4/4 conexiones con coordenadas idénticas confirmadas |

**Resultado:** 98 estaciones distribuidas en 4 líneas, anillo completamente cerrado.

### Fase 1 — Infraestructura Docker

| Paso | Estado | Descripción |
|------|--------|-------------|
| 1.1 Perfil `scenario-mb` | COMPLETADO | DB `:5436`, API `:8083`, volumen y red aislados |
| 1.2 Perfil `scenario-metro` | COMPLETADO | DB `:5437`, API `:8084`, volumen y red aislados |
| 1.3 Volúmenes dedicados | COMPLETADO | `pgdata_scenario_mb`, `pgdata_scenario_metro` |
| 1.4 Redes aisladas | COMPLETADO | `apimetro_net_scenario_mb`, `apimetro_net_scenario_metro` |

**Archivo modificado:** `docker-compose.yml`

### Fase 2 — Migraciones SQL

| Paso | Estado | Descripción |
|------|--------|-------------|
| 2.1 Migración escenario MB | COMPLETADO | `db/migrations/v4.0_anillar_mb.sql` — 118 INSERTs idempotentes |
| 2.2 Migración escenario METRO | COMPLETADO | `db/migrations/v4.0_anillar_metro.sql` — 118 INSERTs idempotentes |
| 2.3 Script de rollback | COMPLETADO | `scripts/anillar_cleanup.sql` — DELETE por rangos de ID |
| 2.4 Targets Makefile | COMPLETADO | 8 targets: docker-scenario-*, anillar-*-setup, anillar-status, anillar-cleanup |

**Contenido por escenario:**
- 4 líneas (con `jerarquia_transporte`, `derecho_de_via`, `capacidad_vehiculo`)
- 98 estaciones (con `geom` POINT PostGIS)
- 8 ramales (2 por línea: ida `ramal_num=1` + regreso `ramal_num=0`, con `geom` MultiLineString)
- 8 historico_operacion (velocidad y frecuencia por ramal)

### Fase 3 — Documentación

| Paso | Estado | Descripción |
|------|--------|-------------|
| 3.1 Guía de activación | COMPLETADO | `docs/ANILLAR_EXTENSION.md` |
| 3.2 Notas VFTModel | PRE-EXISTENTE | `docs/NOTAS_REPLICABILIDAD_PROPUESTA.md` |
| 3.3 Este tracking | COMPLETADO | `docs/TRACKING_ANILLAR_PERIFERICO.md` |

### Fase 4 — Commit y versionamiento

| Paso | Estado | Descripción |
|------|--------|-------------|
| 4.1 Commit inicial | PENDIENTE | Todos los archivos generados en Fases 0-3 |
| 4.2 Push a origin | PENDIENTE | `feat/propuesta-anillar` |

### Fase 5 — Testing Docker

| Paso | Estado | Descripción |
|------|--------|-------------|
| 5.1 Levantar scenario-mb | PENDIENTE | `make docker-scenario-mb` |
| 5.2 Cargar datos MB | PENDIENTE | `make anillar-mb-setup` |
| 5.3 Verificar endpoint estaciones MB | PENDIENTE | `curl localhost:8083/movilidad/mapas/geojsonEstacion?sistema=MB&existe=false` |
| 5.4 Verificar endpoint líneas MB | PENDIENTE | `curl localhost:8083/movilidad/mapas/geojsonLinea?sistema=MB&existe=false` |
| 5.5 Validar formato GeoJSON vs requisitos VFTModel | PENDIENTE | Campos: sistema, tipo_entidad, jerarquia_transporte, derecho_de_via, sentido, velocidad, frecuencia |
| 5.6 Levantar scenario-metro | PENDIENTE | `make docker-scenario-metro` |
| 5.7 Cargar datos METRO | PENDIENTE | `make anillar-metro-setup` |
| 5.8 Verificar endpoints METRO | PENDIENTE | Mismas validaciones que MB |
| 5.9 Verificar aislamiento | PENDIENTE | Confirmar que los datos de un escenario no aparecen en el otro |

### Fase 6 — Entrega

| Paso | Estado | Descripción |
|------|--------|-------------|
| 6.1 Handoff en issue GitHub | PENDIENTE | Documentar estado, comandos, decisiones |
| 6.2 PR hacia DEV | PENDIENTE | `feat/propuesta-anillar` → `DEV` |
| 6.3 Notificar equipo VFTModel | PENDIENTE | URLs, puertos, comandos de setup |

---

## Decisiones técnicas clave

1. **No se crea sistema nuevo** — Se reutilizan `MB` y `METRO` del middleware existente para evitar cambios de código
2. **IDs en rangos altos** — 2xxxx (MB) y 3xxxx (METRO) lejos del max actual (1612) para evitar colisiones
3. **`clasificacion = 'propuesta_periferico'`** — Permite filtrar/excluir sin tocar endpoints
4. **Estaciones puente con coords idénticas** — VFTModel usa `node_id = (lon, lat)`, coords iguales = nodo compartido
5. **2 ramales por línea** — VFTModel usa DiGraph, sin ambos sentidos los caminos mínimos fallan
6. **ST_MakeLine desde puntos de estación** — Cumple tolerancia de snap 50m por definición (los puntos SON el trazo)
7. **historico_operacion obligatorio** — Sin él, velocidad/frecuencia llegan como `null` al GeoJSON

## Parámetros por escenario

| Propiedad | MB (BRT) | METRO |
|-----------|----------|-------|
| sistema | MB | METRO |
| jerarquia_transporte | masivo_mediano | masivo_pesado |
| derecho_de_via | confinado | exclusivo |
| velocidad_promedio_kmh | 16.3 | 36.0 |
| frecuencia_minutos | 5.0 | 3.0 |
| capacidad_vehiculo | 160 | 1000 |
| Fricción (CF) en VFTModel | 1.152 (α=0.2) | 1.0 (α=0.0) |

## Distribución de estaciones por línea

| Línea | ID | Estaciones | Primera | Última | Alcaldías |
|-------|-----|-----------|---------|--------|-----------|
| Sur | 71 | 25 | Periférico Oriente/Tláhuac | Luis Cabrera | Iztapalapa, Tláhuac, Xochimilco, Tlalpan, Coyoacán, Álvaro Obregón, La Magdalena Contreras |
| Poniente | 72 | 31 | Luis Cabrera | Parque Naucalli | La Magdalena Contreras, Álvaro Obregón, Benito Juárez, Miguel Hidalgo, Naucalpan de Juárez |
| Norte | 73 | 24 | Parque Naucalli | Colonias de Aragón | Naucalpan de Juárez, Tlalnepantla de Baz, Azcapotzalco, Gustavo A. Madero, Ecatepec de Morelos, Nezahualcóyotl |
| Oriente | 74 | 18 | Colonias de Aragón | Periférico Oriente/Tláhuac | Nezahualcóyotl, Venustiano Carranza, Iztacalco, Iztapalapa |
