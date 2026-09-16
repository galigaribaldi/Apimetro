# Extensión Anillo Periférico Interior

**Fecha:** 2026-09-16
**Estado:** Listo para carga
**Clasificación de datos:** `propuesta_periferico`

---

## Descripción

Propuesta académica que modela el Anillo Periférico Interior de la ZMVM como sistema de transporte masivo. Se generan 2 escenarios aislados para análisis comparativo con VFTModel:

| Escenario | Sistema | Puerto API | Puerto DB | Perfil Docker |
|-----------|---------|-----------|----------|---------------|
| **BRT (Metrobús)** | `MB` | `:8083` | `:5436` | `scenario-mb` |
| **Metro** | `METRO` | `:8084` | `:5437` | `scenario-metro` |

Cada escenario contiene la **red actual completa** más las 4 líneas del Anillo Periférico Interior.

---

## Estructura de datos

### 4 Líneas (por escenario)

| Línea | Nombre | Estaciones | Dirección |
|-------|--------|-----------|-----------|
| Sur (AP71) | Periférico Interior Sur | 25 | Oriente → Poniente |
| Poniente (AP72) | Periférico Interior Poniente | 31 | Sur → Norte |
| Norte (AP73) | Periférico Interior Norte | 24 | Poniente → Oriente |
| Oriente (AP74) | Periférico Interior Oriente | 18 | Norte → Sur |

**Total: 98 estaciones, 8 ramales (ida + regreso), 8 registros históricos por escenario.**

### Conectividad del anillo

Las 4 líneas forman un anillo cerrado. La última estación de cada línea comparte coordenadas exactas con la primera estación de la siguiente:

```
L71 Sur ──→ Luis Cabrera ════ Luis Cabrera ──→ L72 Poniente
L72 Poniente ──→ Parque Naucalli ══════ Parque Naucalli ──→ L73 Norte
L73 Norte ──→ Colonias de Aragón ══════ Colonias de Aragón ──→ L74 Oriente
L74 Oriente ──→ Periférico Oriente/Tláhuac ══════ Periférico Oriente/Tláhuac ──→ L71 Sur
```

### IDs y rangos

| Elemento | Escenario MB | Escenario METRO |
|----------|-------------|-----------------|
| Líneas (lineas.id) | 2071–2074 | 3071–3074 |
| Estaciones (estacions.id) | 20001–20098 | 30001–30098 |
| estacion_id_oficial | 20001–20098 | 30001–30098 |
| num_comercial | AP71–AP74 | AP71–AP74 |

### Parámetros operativos

| Propiedad | MB | METRO |
|-----------|-----|-------|
| jerarquia_transporte | masivo_mediano | masivo_pesado |
| derecho_de_via | confinado | exclusivo |
| velocidad_promedio_kmh | 16.3 | 36.0 |
| frecuencia_minutos | 5.0 | 3.0 |
| capacidad_vehiculo | 160 | 1000 |

---

## Guía de activación

### Pre-requisitos

- Docker y docker-compose instalados
- Archivos `.env.dev` en `~/.SecretsFiles/` (mismos que el entorno DEV)
- Seed de datos (`04_seed.sql`) en `db/init/`

### Paso 1 — Levantar entorno

```bash
# Escenario MB (BRT)
make docker-scenario-mb

# Escenario METRO
make docker-scenario-metro
```

Esperar a que los contenedores estén saludables (~30s la primera vez).

### Paso 2 — Cargar datos del anillo

```bash
# Escenario MB
make anillar-mb-setup

# Escenario METRO
make anillar-metro-setup
```

### Paso 3 — Verificar

```bash
# Verificar conteos en escenario MB
make anillar-status CONTAINER=apimetro_db_scenario_mb

# Verificar conteos en escenario METRO
make anillar-status CONTAINER=apimetro_db_scenario_metro
```

Resultado esperado:
```
  tabla      | count
-------------+-------
 lineas      |     4
 estacions   |    98
 ramals      |     8
 historico_op|     8
```

### Paso 4 — Probar endpoints

```bash
# Estaciones del anillo (MB)
curl "http://localhost:8083/movilidad/mapas/geojsonEstacion?sistema=MB&existe=false"

# Líneas del anillo (MB)
curl "http://localhost:8083/movilidad/mapas/geojsonLinea?sistema=MB&existe=false"

# Estaciones del anillo (METRO)
curl "http://localhost:8084/movilidad/mapas/geojsonEstacion?sistema=METRO&existe=false"
```

### Paso 5 — Conectar VFTModel

```bash
# .env.scenario-mb
APIMETRO_URL=http://localhost:8083/movilidad

# .env.scenario-metro
APIMETRO_URL=http://localhost:8084/movilidad
```

---

## Bajar y limpiar

```bash
# Bajar entornos
make docker-down-scenario-mb
make docker-down-scenario-metro

# Limpiar datos sin bajar contenedores
make anillar-cleanup CONTAINER=apimetro_db_scenario_mb
make anillar-cleanup CONTAINER=apimetro_db_scenario_metro
```

---

## Archivos de este feature

```
db/migrations/
  v4.0_anillar_mb.sql          ← Migración escenario MB (idempotente)
  v4.0_anillar_metro.sql       ← Migración escenario METRO (idempotente)
ETL/Data/Anillar/
  estaciones_periferico_interior.csv  ← CSV maestro (98 estaciones, corregido)
scripts/
  anillar_cleanup.sql          ← Rollback (DELETE por rango de IDs)
docs/
  ANILLAR_EXTENSION.md         ← Esta guía
  NOTAS_REPLICABILIDAD_PROPUESTA.md  ← Notas técnicas de VFTModel
docker-compose.yml             ← Perfiles scenario-mb y scenario-metro
Makefile                       ← Targets anillar-*
```
