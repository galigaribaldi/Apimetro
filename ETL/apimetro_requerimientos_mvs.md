# Requerimientos VFT → Apimetro: Vistas Materializadas

**Fecha:** 2026-04-28
**Destinatario:** Equipo Apimetro
**Contexto:** Definición de las columnas requeridas por el motor VFT para el cálculo del Node Score (peso ponderado por estación).

---

## Las dos fórmulas del modelo VFT

VFT opera con dos tipos de peso que no deben confundirse:

### Tipo A — Edge Weight (routing / caminos mínimos) ✅ Ya definido

```
w(u,v) = (D_uv / V_modo) × CF_via + W_transbordo
```

| Variable | Descripción | Fuente |
|---|---|---|
| `D_uv` | Distancia real del segmento (`distancia_segmento_m`) | Apimetro — endpoints actuales |
| `V_modo` | Velocidad por tipo de sistema | VFT interno (`impedance.py`) |
| `CF_via` | Coeficiente de fricción vial | VFT interno (`impedance.py`) |
| `W_transbordo` | Penalización de transbordo (caminata + espera) | VFT interno (`graph_builder.py`) |

**Sin dependencia de nuevas MVs.** Usado por: Dijkstra, Detour Factor, Tiempo de Viaje Promedio (P3), Centralidad de Intermediación (P4).

---

### Tipo B — Node Score (importancia / ranking de nodos) ⬅ Este documento

```
VFT_score_i = α₁·k̂ᵢ + α₂·âᵢ + α₃·p̂ᵢ   [+ α₄·ôdᵢ en fase posterior]
```

| Símbolo | Componente | Fuente |
|---|---|---|
| `k̂ᵢ` | Fuerza capilar normalizada | VFT interno — ya calculado |
| `âᵢ` | Afluencia estimada por estación | **Requiere MV1 de Apimetro** |
| `p̂ᵢ` | Población captada en buffer 800m | **Requiere MV2 de Apimetro** |
| `ôdᵢ` | Flujo OD asignado por estación | Fase posterior — no bloquea implementación actual |

**Nota sobre cercanía a otros modos:** este factor ya está capturado por `k̂ᵢ` (la fuerza capilar mide exactamente la conectividad intermodal de cada nodo). No requiere componente separado.

---

## MV1 — Afluencia por Línea

### Propósito

VFT necesita el total de pasajeros por línea para distribuirlos entre las estaciones que la componen. La desagregación línea → estación la realiza VFT internamente. **Apimetro no necesita entregar datos por estación.**

### Granularidad requerida: **por línea**

### Columnas requeridas

| Columna | Tipo | Descripción | Obligatorio |
|---|---|---|---|
| `id_linea` | `UUID / FK` | Identificador único de línea (mismo que en endpoints actuales) | ✅ |
| `nombre_linea` | `VARCHAR` | Nombre legible (ej: `"Línea 3"`) | ✅ |
| `sistema` | `ENUM` | `Metro` / `Metrobús` / `RTP` / `CC` / `Tren Ligero` / `Tren Suburbano` | ✅ |
| `afluencia_diaria_promedio` | `FLOAT` | Pasajeros/día promedio — abordajes | ✅ |
| `tipo_afluencia` | `ENUM` | `abordajes` / `ascensos_descensos` / `ODT` | ✅ |
| `periodo_inicio` | `DATE` | Inicio del periodo de medición | ✅ |
| `periodo_fin` | `DATE` | Fin del periodo de medición | ✅ |
| `fuente` | `VARCHAR` | STCM / SEMOVI / CDMX Open Data / etc. | ✅ |
| `afluencia_hora_pico` | `FLOAT` | Pasajeros en hora pico (opcional) | ⬜ |
| `dia_tipo` | `ENUM` | `laboral` / `sabado` / `domingo` / `promedio` | ⬜ |

### Notas críticas

- **`tipo_afluencia` es obligatorio.** `abordajes` (solo sube) ≠ `ascensos_descensos` (sube + baja). La fórmula de desagregación interna de VFT cambia según el tipo.
- Si existen datos por día de semana, priorizar `dia_tipo = 'laboral'` como valor base del modelo.
- Cobertura mínima requerida: Metro, Metrobús, RTP, CC, Tren Ligero, Tren Suburbano.

---

## MV2 — AGEBs con Atributos Censales

### Propósito

VFT intersecta los polígonos AGEB con buffers de 800m alrededor de cada estación para calcular la **población real captada** por estación. Esto convierte el indicador de cobertura de "área cubierta" a "personas cubiertas", dando rigor demográfico al modelo.

### Granularidad requerida: **por AGEB**

### Columnas requeridas

| Columna | Tipo | Descripción | Obligatorio |
|---|---|---|---|
| `clave_ageb` | `VARCHAR(12)` | Clave INEGI completa (ej: `090030001001`) | ✅ |
| `geom` | `GEOMETRY(Polygon, 4326)` | Polígono del AGEB en **WGS84** | ✅ |
| `entidad` | `VARCHAR` | `CDMX` / `Estado de México` | ✅ |
| `municipio_alcaldia` | `VARCHAR` | Alcaldía o municipio | ✅ |
| `poblacion_total` | `INTEGER` | Personas residentes — Censo INEGI 2020 | ✅ |
| `viviendas_habitadas` | `INTEGER` | Proxy de densidad residencial | ✅ |
| `area_km2` | `FLOAT` | Área del AGEB en km² | ✅ |
| `densidad_pob_km2` | `FLOAT` | `poblacion_total / area_km2` | ✅ |
| `nivel_se` | `INTEGER` | Nivel socioeconómico AMAI (1–7) o CONAPO (1–5) | ⬜ |
| `pea` | `INTEGER` | Población económicamente activa | ⬜ |

### Notas críticas

- **La geometría debe estar en WGS84 (EPSG:4326)** — el motor VFT opera en este CRS.
- **Cobertura geográfica requerida:** CDMX completa + municipios conurbados del Estado de México presentes en el grafo: Naucalpan, Ecatepec, Nezahualcóyotl, Tlalnepantla, Tultitlán, Cuautitlán Izcalli.
- `nivel_se` no bloquea la fase actual pero habilita el escenario de análisis de equidad social del modelo.

---

## División de responsabilidades

| Tarea | Apimetro | VFT |
|---|---|---|
| Exponer afluencia por línea | ✅ | — |
| Desagregar afluencia línea → estación | — | ✅ |
| Exponer polígonos AGEB con censo | ✅ | — |
| Buffer espacial 800m por estación | — | ✅ |
| Intersección AGEB × buffer | — | ✅ |
| Normalización de componentes [0,1] | — | ✅ |
| Cálculo de pesos α (entropía/escenarios) | — | ✅ |
| Geometría estaciones y rutas (ya existe) | ✅ ya disponible | — |

---

## Fase posterior — MV3 Matriz OD (sin ETA definido)

No bloquea la implementación actual. Cuando esté disponible, VFT la consume para agregar el componente `ôdᵢ` al Node Score. Granularidad requerida: **por ZAT (Zona de Análisis de Tránsito)** con geometría de zona + flujos O→D en transporte público.

---

## Resumen ejecutivo

El peso ponderado de una estación en VFT es una **combinación de tres componentes**:

1. **Fuerza capilar** `k̂ᵢ` — topológica, calculada internamente por VFT
2. **Afluencia estimada** `âᵢ` — derivada de la afluencia **por línea** que entrega Apimetro; VFT desagrega a estación internamente
3. **Población captada** `p̂ᵢ` — derivada de los polígonos **AGEB** con atributos censales que entrega Apimetro; VFT hace la intersección espacial

La cercanía a otros modos ya está capturada por la fuerza capilar. La Matriz OD se incorpora en fase posterior.

**Apimetro necesita exponer dos MVs nuevas:** afluencia por línea y AGEBs con censo (WGS84, cobertura CDMX + municipios conurbados EdoMex).
