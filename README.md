# Apimetro API

![Go Version](https://img.shields.io/badge/Go-1.25-00ADD8?style=flat&logo=go)
![Gin Gonic](https://img.shields.io/badge/Gin-Framework-00ADD8?style=flat)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-PostGIS-336791?style=flat&logo=postgresql)
![Swagger](https://img.shields.io/badge/Swagger-Documented-85EA2D?style=flat&logo=swagger)
![Docker](https://img.shields.io/badge/Docker-Multi--Entorno-2496ED?style=flat&logo=docker)
![License](https://img.shields.io/badge/License-BSL%201.1-orange.svg)

**Apimetro** es una API RESTful desarrollada en Go que proporciona información detallada y georreferenciada sobre el Sistema de Transporte Colectivo (STC) y otros sistemas de movilidad de la Ciudad de México y su área metropolitana.

Diseñada para integrarse con mapas y sistemas de información geográfica (SIG), devuelve geometrías directamente en formato **GeoJSON** estándar — lista para consumirse con Leaflet, Mapbox, MapLibre o cualquier cliente de mapas.

> **Modelo de uso:** Apimetro es un proyecto de software libre con modelo **Freemium**. El uso personal, educativo, de investigación y del sector público es gratuito. El uso comercial requiere una licencia. Consulta el archivo [LICENSE](./LICENSE) para más detalles o escribe a galigaribaldi0@gmail.com.

---

## Servidor de Producción

| Recurso | URL |
|---------|-----|
| API base | `https://apimetro.dev/movilidad` |
| Swagger UI | `https://apimetro.dev/swagger/` |
| Health check | `https://apimetro.dev/` |

```bash
# Ejemplo rápido — líneas del Metro en producción
curl "https://apimetro.dev/movilidad/metro/linea?existe=true"
```

---

## Características Principales

- **Respuestas GeoJSON** — Los endpoints de mapas devuelven `FeatureCollection` listos para renderizar en cualquier librería de mapas.
- **Consultas Espaciales** — PostGIS nativo: `ST_AsGeoJSON`, `ST_DWithin`, `ST_Length`, `ST_Union`.
- **Filtrado Avanzado** — Por sistema, alcaldía, CETRAM, jerarquía de transporte, sentido, número comercial y más.
- **Métricas Operativas** — Velocidad promedio (km/h), frecuencia (min), capacidad de vehículo y distancia por ramal.
- **Documentación Interactiva** — Swagger UI disponible en `/swagger/` con todos los esquemas y parámetros documentados.
- **Multi-entorno con Docker** — Perfiles separados para DEV, QA y MAIN con volúmenes y redes independientes.

---

## Sistemas de Transporte Cubiertos

| Clave | Sistema |
|-------|---------|
| `METRO` | Sistema de Transporte Colectivo Metro |
| `MB` | Metrobús |
| `CBB` | Cablebús |
| `RTP` | Red de Transporte de Pasajeros |
| `TROLE` | Servicio de Transportes Eléctricos (Trolebús) |
| `TL` | Tren Ligero |
| `MEXIBUS` | Mexibús |
| `MEXICABLE` | Mexicable |
| `INTERURBANO` | Tren Interurbano México-Toluca |
| `CC` | Cable Car |
| `TODOS` | Todos los sistemas simultáneamente |

---

## Tecnologías

| Capa | Tecnología |
|------|-----------|
| Lenguaje | [Go 1.25](https://golang.org/) |
| Framework web | [Gin v1.9](https://github.com/gin-gonic/gin) |
| Base de datos | [PostgreSQL 15](https://www.postgresql.org/) + [PostGIS 3.4](https://postgis.net/) |
| ORM | [GORM v1.25](https://gorm.io/) |
| Documentación | [Swaggo v1.16](https://github.com/swaggo/swag) |
| Contenedores | [Docker](https://www.docker.com/) + Docker Compose |
| Hot reload | [Air](https://github.com/air-verse/air) |

---

## Requisitos Previos

### Opción A — Desarrollo local (sin Docker)
- Go 1.25+
- PostgreSQL 15+ con extensión PostGIS habilitada
- [`swag`](https://github.com/swaggo/swag) y [`air`](https://github.com/air-verse/air) instalados en `~/go/bin/`

### Opción B — Docker (recomendado)
- Docker Engine 24+
- Docker Compose v2+
- `make`

---

## Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/galigaribaldi/Apimetro.git
cd Apimetro
```

### 2. Descargar dependencias de Go

```bash
go mod tidy
```

### 3. Instalar herramientas de desarrollo

```bash
go install github.com/swaggo/swag/cmd/swag@latest
go install github.com/air-verse/air@latest
```

---

## Ejecución

### Desarrollo local (sin Docker)

```bash
make dev
```
Genera la documentación Swagger y levanta el servidor con hot-reload en `http://localhost:8080`.

La API se conecta por defecto a `postgresql://prueba:postgres@localhost:5432/db_apimetro`. Configura las variables de entorno `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` y `DB_NAME` para apuntar a otra base de datos.

### Desarrollo con Docker

```bash
make docker-dev
```
Levanta la API en `http://localhost:8080` y PostgreSQL+PostGIS en el puerto `5433`.

Para QA y producción:

```bash
make docker-qa    # API :8081 | DB :5434
make docker-main  # API :8082 | DB :5435
```

Consulta [`db/NOTES.txt`](./db/NOTES.txt) para instrucciones detalladas de cada entorno, incluyendo carga de datos e inicialización de la base de datos.

---

## Documentación de la API

Accede a la documentación interactiva:

- **Producción:** `https://apimetro.dev/swagger/`
- **Local:** `http://localhost:8080/swagger/`

**Base path:** `/movilidad`

Para regenerar la documentación después de modificar anotaciones:

```bash
make docs
```

---

## Endpoints Principales

### GeoJSON — Trazos y geometrías

Todos devuelven un objeto `FeatureCollection` bajo el estándar GeoJSON RFC 7946.

#### `GET /movilidad/mapas/geojsonEstacion`
Estaciones de transporte como puntos georreferenciados.

**Parámetros:** `sistema`, `num_comercial`, `alcaldia_municipio`, `nombre_ramal`, `jerarquia_transporte`, `derecho_de_via`, `es_cetram`, `nombre_cetram`, `cetram_real`

#### `GET /movilidad/mapas/geojsonLinea`
Trazos de líneas con métricas operativas (velocidad, frecuencia, capacidad, distancia).

**Parámetros:** `sistema`, `num_comercial`, `nombre_ramal`, `jerarquia_transporte`, `derecho_de_via`, `es_cetram`, `sentido`, `existe`

#### `GET /movilidad/mapas/geojsonPoligono`
Límites administrativos: alcaldías de la CDMX y municipios del Área Metropolitana.

**Parámetros:** `entidad`, `nivel`, `nombre`

### Datos descriptivos — CRUD por sistema

```
GET  /movilidad/{sistema}/linea
POST /movilidad/{sistema}/linea
PATCH /movilidad/{sistema}/linea?id={id}
DELETE /movilidad/{sistema}/linea?id={id}

GET  /movilidad/{sistema}/estacion
POST /movilidad/{sistema}/estacion
PATCH /movilidad/{sistema}/estacion?id={id}
DELETE /movilidad/{sistema}/estacion?id={id}

GET  /movilidad/{sistema}/descripcion-linea
GET  /movilidad/{sistema}/descripcion-estacion
```

### Ejemplo de consulta

```bash
# Estaciones tipo CETRAM del METRO en formato GeoJSON
curl "https://apimetro.dev/movilidad/mapas/geojsonEstacion?sistema=METRO&es_cetram=true"

# Líneas del Metrobús actualmente en operación
curl "https://apimetro.dev/movilidad/MB/linea?existe=true"

# Polígonos de alcaldías de la CDMX
curl "https://apimetro.dev/movilidad/mapas/geojsonPoligono?entidad=CDMX&nivel=alcaldia"
```

---

## Estructura del Proyecto

```
Apimetro/
├── cmd/
│   ├── main.go                        # Entry point + anotaciones Swagger globales
│   ├── docs/                          # Swagger autogenerado (no editar manualmente)
│   └── pkg/
│       ├── controller/
│       │   ├── Controller.go          # Conexión a DB y AutoMigrate
│       │   ├── geojson/               # Consultas espaciales PostGIS
│       │   ├── transporte/            # CRUD de entidades
│       │   ├── middleware/            # Validación del parámetro :sistema
│       │   └── utils/                 # Structs para mapear resultados SQL
│       ├── models/                    # Structs GORM + modelos GeoJSON
│       └── routes/                    # Handlers HTTP + anotaciones Swagger
├── db/
│   ├── init/
│   │   ├── init.sql                   # DDL completo (tablas, índices, esquemas)
│   │   ├── roles.sh                   # Creación del rol apimetro_read
│   │   └── seed.sql                   # Datos de transporte (no incluido en git)
│   └── NOTES.txt                      # Guía de comandos y operaciones de DB
├── .env.dev                           # Variables de entorno DEV (no en git)
├── .env.qa                            # Variables de entorno QA (no en git)
├── .env.main                          # Variables de entorno MAIN (no en git)
├── docker-compose.yml                 # Orquestación multi-entorno
├── Dockerfile                         # Build de producción (multi-stage)
├── Makefile                           # Comandos de desarrollo y despliegue
├── .air.toml                          # Configuración de hot-reload
└── go.mod                             # Dependencias de Go
```

---

## Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `DB_HOST` | Host de la base de datos | `localhost` / `db_dev` |
| `DB_PORT` | Puerto de PostgreSQL | `5432` |
| `DB_NAME` | Nombre de la base de datos | `db_apimetro` |
| `DB_USER` | Usuario de la API (solo lectura) | `apimetro_read` |
| `DB_PASSWORD` | Contraseña del usuario API | `***` |
| `DATABASE_URL` | DSN completo (sobreescribe los anteriores) | `postgresql://user:pass@host/db` — la contraseña debe estar URL-encoded si contiene `/`, `+` o `=` |
| `GIN_MODE` | Modo del servidor Gin | `debug` / `release` |

> En desarrollo local sin Docker, si `DB_HOST` está vacío o es `localhost`, la API ejecutará `AutoMigrate` de GORM automáticamente. En Docker, el esquema es gestionado por `db/init/init.sql`.

---

## Contribuciones

Las contribuciones son bienvenidas para uso no comercial. Para contribuir:

1. Haz un fork del repositorio.
2. Crea una rama: `git checkout -b feature/mi-mejora`
3. Haz commit de tus cambios: `git commit -m 'feat: descripción del cambio'`
4. Abre un Pull Request describiendo los cambios.

Si planeas usar Apimetro en un contexto comercial, contacta primero al autor para discutir una licencia comercial.

---

## Licencia

Este proyecto está licenciado bajo la **Business Source License 1.1 (BSL 1.1)**.

- **Uso gratuito:** personal, académico, investigación, periodismo y sector público.
- **Uso comercial:** requiere licencia — contacta a galigaribaldi0@gmail.com.
- **Conversión a Apache 2.0:** el **12 de abril de 2029**, este proyecto se convierte automáticamente en software libre bajo Apache 2.0.

Consulta el archivo [LICENSE](./LICENSE) para el texto completo.

---

## Contacto

**Hernán Galileo Cabrera Garibaldi**
- GitHub: [@galigaribaldi](https://github.com/galigaribaldi)
- Email: galigaribaldi0@gmail.com
