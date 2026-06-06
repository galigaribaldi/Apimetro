# Plutarco — Plan de Implementación para VFT

**Fecha:** 2026-04-28  
**Estado:** En planificación — pendiente decisión de scope geográfico  
**Contexto:** Extensión analítica del esquema `plutarco` en PostgreSQL/PostGIS para alimentar los pesos ponderados del motor analítico VFT (Valor de Flujo de Transporte).

---

## ¿Qué es Plutarco en este contexto?

El esquema `plutarco` en `db_apimetro` ya existe con tablas vacías (`agebs`, `calles`). Esta implementación lo convierte en la capa analítica que Apimetro expone al modelo VFT. Apimetro actúa como fuente de datos geoespaciales y de afluencia; VFT consume esos datos para calcular el Node Score de cada estación.

---

## Las dos fórmulas VFT

### Tipo A — Edge Weight (ya definido, sin dependencia de nuevas MVs)
```
w(u,v) = (D_uv / V_modo) × CF_via + W_transbordo
```
- `D_uv`: distancia real del segmento — Apimetro la expone vía geometría de `ramals`
- `V_modo`, `CF_via`, `W_transbordo`: calculados internamente por VFT (`impedance.py`, `graph_builder.py`)
- **Apimetro no necesita nuevas MVs para esto.** Los endpoints actuales son suficientes.

### Tipo B — Node Score (pendiente de implementar)
```
VFT_score_i = α₁·k̂ᵢ + α₂·âᵢ + α₃·p̂ᵢ  [+ α₄·ôdᵢ en fase posterior]
```

| Símbolo | Componente | Responsable |
|---|---|---|
| `k̂ᵢ` | Fuerza capilar normalizada (conectividad topológica) | VFT interno |
| `âᵢ` | Afluencia estimada por estación | **Apimetro → MV1** |
| `p̂ᵢ` | Población captada en buffer 800m | **Apimetro → MV2** |
| `ôdᵢ` | Flujo OD por estación | Fase posterior — no bloquea |

**División de responsabilidades clave:**
- Apimetro expone afluencia POR LÍNEA (VFT desagrega a estación internamente)
- Apimetro expone AGEBs con atributos censales (VFT hace el buffer 800m y la intersección)
- Apimetro NO normaliza ni calcula scores — eso es VFT

---

## Topología del grafo (GAP 1 — resuelto)

**Decisión: Opción B** — usar `num_estacion` + `linea_id` para inferir pares consecutivos de estaciones (aristas del grafo). No se requiere agregar `ramal_id` a `estacions` en esta fase.

- Aristas: pares `(est_n, est_{n+1})` ordenados por `num_estacion` dentro de cada `linea_id`
- Limitación documentada: MEXIBÚS y MEXICABLE tienen `num_estacion IS NULL` → no generan aristas (issue #35)
- VFT no requiere nueva MV para TIPO A. Computa distancias desde geometrías de `ramals`.

---

## Estándar de clave AGEB — definido aquí, pasarlo a VFT

```
clave_ageb = CVE_ENT(2) + CVE_MUN(3) + CVE_LOC(4) + CVE_AGEB(4) = 13 chars
```

Ejemplo: `0900200010010` = CDMX(09) + Azcapotzalco(002) + Localidad 1(0001) + AGEB(0010)

- Tipo: `VARCHAR(13)` — alfanumérico (algunos AGEBs tienen letras: `003A`, `010A`)
- **El documento VFT indica VARCHAR(12) — INCORRECTO. Corregir a VARCHAR(13).**
- Campo en la BD: `cvegeo`
- Construcción desde CSV INEGI: `LPAD(ENTIDAD,2,'0') || LPAD(MUN,3,'0') || LPAD(LOC,4,'0') || AGEB`
- En EdoMex LOC NO es siempre `0001` — varía, por eso los 4 dígitos son obligatorios

---

## Datos disponibles y su estado

### Shapefiles de AGEBs

| Estado | Archivo | Features | CRS | Acción ETL |
|---|---|---|---|---|
| CDMX (09) | `ETL/Data/AGEBS/poligono_ageb_urbanas_cdmx/poligono_ageb_urbanas_cdmx.shp` | 2,431 | WGS84 ✅ | Cargar directo |
| EdoMex (15) | `ETL/Data/AGEBS/15_mexico/conjunto_de_datos/15a.shp` | 4,375 | ITRF2008/LCC ⚠️ | Reproyectar a WGS84 |
| Morelos (17) | `ETL/Data/AGEBS/17_morelos/conjunto_de_datos/17a.shp` | 1,025 | ITRF2008/LCC ⚠️ | Reproyectar a WGS84 |
| Puebla (21) | `ETL/Data/AGEBS/21_puebla/conjunto_de_datos/21a.shp` | 2,513 | ITRF2008/LCC ⚠️ | Reproyectar a WGS84 |
| Querétaro (22) | `ETL/Data/AGEBS/22_queretaro/conjunto_de_datos/22a.shp` | 928 | ITRF2008/LCC ⚠️ | Reproyectar a WGS84 |
| Tlaxcala (29) | `ETL/Data/AGEBS/29_tlaxcala/conjunto_de_datos/29a.shp` | 675 | ITRF2008/LCC ⚠️ | Reproyectar a WGS84 |

Reproyección con geopandas: `gdf.to_crs(epsg=4326)` — una línea, no bloqueante.

### CSVs de Censo 2020 INEGI

| Estado | Archivo | AGEBs reales (MZA=000) | Estructura |
|---|---|---|---|
| CDMX (09) | `ETL/Data/Censo/ageb_mza_urbana_09_cpv2020/conjunto_de_datos/...csv` | 2,433 | Formato A |
| EdoMex (15) | `ETL/Data/Censo/RESAGEBURB_15CSV20.csv` | 4,465 | Formato B (idéntico) |
| Morelos (17) | `ETL/Data/Censo/RESAGEBURB_17CSV20.csv` | 1,021 | Formato B |
| Puebla (21) | `ETL/Data/Censo/RESAGEBURB_21CSV20.csv` | 2,503 | Formato B |
| Querétaro (22) | `ETL/Data/Censo/RESAGEBURB_22CSV20.csv` | 891 | Formato B |
| Tlaxcala (29) | `ETL/Data/Censo/RESAGEBURB_29CSV20.csv` | 668 | Formato B |

**Columnas clave (posición idéntica en ambos formatos):**
- `POBTOT` → col #8 → `poblacion_total`
- `TVIVHAB` → col #178 → `viviendas_habitadas`
- `PEA` → col #142 → `pea`
- `NOM_ENT` → col #1 → `entidad`
- `NOM_MUN` → col #3 → `municipio_alcaldia`
- Filtro nivel AGEB: `MZA == '000' AND MUN != '000' AND LOC != '0000' AND AGEB != '0000'`

**JOIN shapefile ↔ CSV CDMX: 2,431/2,431 (100%)** — verificado.

### Municipios EdoMex de interés para VFT (códigos correctos)

| Municipio | CVE_MUN correcto |
|---|---|
| Naucalpan de Juárez | `057` |
| Ecatepec de Morelos | `033` |
| Nezahualcóyotl | `058` |
| Tlalnepantla de Baz | `104` |
| Tultitlán | `109` |
| Cuautitlán Izcalli | `121` |

EdoMex ZMVM: ~3,553 AGEBs (79.6% del total estatal). EdoMex completo: 4,465 AGEBs.

### Archivos de Pesos (afluencia por línea)

Ubicación: `ETL/Data/Pesos/`

| Archivo | Granularidad | Columnas clave |
|---|---|---|
| `afluencia_desglosada_acumulada_2024_07.csv` | Sistema completo + demografía | `anio, mes, hora, genero, rango_edad, viajes` |
| `afluencia_desglosada_cb_03_2026.csv` | Por línea (Cablebús) | `fecha, mes, anio, linea, tipo_pago, afluencia` |
| `afluencia_desglosada_tl_03_2026.csv` | Sistema total (Tren Ligero) | `fecha, mes, anio, tipo_pago, afluencia` |
| `afluencia_desglosada_trolebus_03_2026.csv` | Por línea (Trolebús) | `fecha, mes, anio, linea, tipo_pago, afluencia` |
| `afluenciartp_desglosado_03_2026.csv` | Por servicio (RTP) | `fecha, mes, anio, servicio, tipo_pago, afluencia` |
| `afluencia_diaria_historica.xlsx` | Histórico diario (sistema) | Excel, procesar por separado |
| `MatrizOD.xlsx` | Zonas de Análisis de Tránsito (ZAT) | Fase posterior — no bloquea |

---

## Estimación de espacio en BD

| Escenario | AGEBs | Total en BD (tabla + índices) |
|---|---|---|
| CDMX | 2,431 | ~17 MB |
| CDMX + EdoMex completo | 6,896 | ~47 MB |
| Macrometrópoli completa (6 estados) | 11,979 | ~82 MB |

**Disco disponible en producción: 289 GB.** La diferencia entre scope mínimo y máximo es ~35 MB.

**Costo de consultas espaciales:** idéntico entre escenarios — el índice GiST escala `O(log n)`. Las MVs se precalculan una vez; los endpoints consultan la MV en `<10ms`.

---

## Decisión pendiente al retomar

**Scope geográfico de `plutarco.agebs`:**
- [ ] CDMX + EdoMex completo (~47 MB) — scope mínimo funcional
- [ ] Macrometrópoli completa: CDMX + EdoMex + Morelos + Puebla + Querétaro + Tlaxcala (~82 MB)

**Recomendación:** cargar macrometrópoli completa desde el inicio. Razones:
1. Todos los archivos ya están descargados
2. El ETL es paramétrico — añadir estados = añadir nombres de archivo
3. 35 MB de diferencia en 289 GB disponibles
4. Evita re-correr ETL + re-crear índices + refrescar MVs cuando VFT expanda

---

## Fase posterior — MatrizOD (sin ETA)

No bloquea la implementación actual. Cuando esté disponible:
- Apimetro expone tabla `plutarco.zonas_zat` (geometrías ZAT + flujos OD)
- VFT hace la intersección centroide ZAT → estaciones (radio 800m, peso 1/distancia)
- Granularidad: por ZAT (Zona de Análisis de Tránsito), no por estación

---

## Próximos pasos al retomar

1. **Confirmar scope** (CDMX+EdoMex vs macrometrópoli)
2. **DDL corregido** de `plutarco.agebs` + nuevas tablas:
   - `plutarco.afluencia_linea`
   - `plutarco.catalogo_homologacion`
3. **Script ETL Python** para AGEBs (shapefile + censo → BD)
4. **Script ETL Python** para CSVs de Pesos
5. **MV1** — afluencia por línea (normalizada)
6. **MV2** — AGEBs con atributos censales
7. **Endpoints Go** — nuevas rutas en `/movilidad/analitico/`
8. **Actualizar issue #16** en GitHub con este plan
