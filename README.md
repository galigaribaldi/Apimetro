# 🚇 Apimetro API

![Go Version](https://img.shields.io/badge/Go-1.20+-00ADD8?style=flat&logo=go)
![Gin Gonic](https://img.shields.io/badge/Gin-Framework-00ADD8?style=flat)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-PostGIS-336791?style=flat&logo=postgresql)
![Swagger](https://img.shields.io/badge/Swagger-Documented-85EA2D?style=flat&logo=swagger)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

**Apimetro** es una API RESTful desarrollada en Go que proporciona información detallada y georreferenciada sobre el Sistema de Transporte Colectivo (STC) y otros sistemas de movilidad de la Ciudad de México y su área metropolitana.

La API está diseñada para integrarse fácilmente con mapas y sistemas de información geográfica (SIG) al devolver la información espacial directamente en formato **GeoJSON** estándar.

## ✨ Características Principales

- **Respuestas GeoJSON:** Los endpoints principales devuelven objetos `FeatureCollection` listos para ser consumidos por librerías de mapas (como Leaflet, Mapbox o MapLibre).
- **Consultas Espaciales:** Utiliza PostGIS para la extracción nativa de geometrías (`ST_AsGeoJSON`), cálculo de distancias y agrupación espacial.
- **Filtrado Avanzado:** Capacidad de filtrar datos por sistema, alcaldía, jerarquía de transporte, CETRAMs, sentido, número comercial, entre otros.
- **Documentación Interactiva:** Integración con Swagger UI para probar los endpoints en tiempo real.
- **ORM Eficiente:** Uso de GORM para el manejo de la base de datos y migraciones automáticas.

## 🛠️ Tecnologías Utilizadas

- **Lenguaje:** [Go (Golang)](https://golang.org/)
- **Framework Web:** [Gin Web Framework](https://github.com/gin-gonic/gin)
- **Base de Datos:** [PostgreSQL](https://www.postgresql.org/) con extensión espacial [PostGIS](https://postgis.net/)
- **ORM:** [GORM](https://gorm.io/)
- **Documentación:** [Swaggo (swag)](https://github.com/swaggo/swag)

## 🚀 Requisitos Previos

Para ejecutar este proyecto localmente, necesitas tener instalado:
1. Go (versión 1.20 o superior).
2. PostgreSQL (versión 12 o superior).
3. Extensión PostGIS habilitada en tu base de datos.
4. Git.

## ⚙️ Instalación y Configuración

**1. Clonar el repositorio**
```bash
git clone [https://github.com/galigaribaldi/Apimetro.git](https://github.com/galigaribaldi/Apimetro.git)
cd Apimetro
```

**2. Descargar dependencias**
```bash
go mod tidy
```

**3. Configurar la Base de Datos**
Asegúrate de crear una base de datos en PostgreSQL con la extensión PostGIS:
```sql
CREATE DATABASE db_apimetro;
\c db_apimetro;
CREATE EXTENSION postgis;
```
*(Nota: Las variables de conexión por defecto apuntan a `postgresql://prueba:postgres@localhost:5432/db_apimetro`. Puedes ajustar esto en el archivo `Controller.go` o mediante variables de entorno).*

**4. Compilar la documentación de Swagger (Opcional, si haces cambios)**
```bash
~/go/bin/swag init -g cmd/main.go
```

**5. Ejecutar la API**
```bash
go run cmd/main.go
```
El servidor se levantará por defecto en `http://localhost:8080`.

## 📖 Documentación de la API (Swagger)

La API cuenta con documentación interactiva generada con Swaggo. Una vez que el servidor esté corriendo, puedes acceder a todos los esquemas, modelos y probar los endpoints desde tu navegador.

**Base Path:** `/movilidad`

## 🗺️ Endpoints Principales (GeoJSON)

Todos estos endpoints devuelven un objeto `FeatureCollection` estructurado bajo el estándar GeoJSON:

### `/movilidad/geojsonEstacion`
Obtiene las estaciones del sistema de transporte.
- **Filtros disponibles (Query Params):** `sistema`, `num_comercial`, `alcaldia_municipio`, `nombre_ramal`, `jerarquia_transporte`, `derecho_de_via`, `es_cetram`, `nombre_cetram`, `cetram_real`.

### `/movilidad/geojsonLinea`
Obtiene los trazos de las líneas o rutas con sus métricas operativas (velocidad, frecuencia, capacidad).
- **Filtros disponibles (Query Params):** `sistema`, `num_comercial`, `nombre_ramal`, `jerarquia_transporte`, `derecho_de_via`, `es_cetram`, `sentido`, `existe`.

### `/movilidad/geojsonPoligono`
Obtiene los límites territoriales y administrativos (polígonos).
- **Filtros disponibles (Query Params):** `entidad`, `nivel`, `nombre`.

### Ejemplo de Petición
```bash
curl -X GET "http://localhost:8080/movilidad/geojsonEstacion?sistema=Metrobús&es_cetram=true" -H "accept: application/json"
```

## 📂 Estructura del Proyecto

```text
Apimetro/
├── cmd/
│   ├── main.go               # Punto de entrada de la aplicación
│   ├── docs/                 # Archivos autogenerados por Swagger
│   └── pkg/
│       ├── controller/       # Lógica de base de datos y consultas GeoJSON
│       ├── models/           # Estructuras de datos (GORM y GeoJSON)
│       └── routes/           # Definición de rutas (Gin) y anotaciones Swagger
├── go.mod                    # Dependencias de Go
└── README.md                 # Documentación del proyecto
```

## 📄 Licencia

Este proyecto está bajo la Licencia **Apache 2.0**. Consulta el archivo de licencia para más detalles.

## 📧 Contacto

**Galileo Cabrera Garibaldi**
- GitHub: [@galigaribaldi](https://github.com/galigaribaldi)
- Email: galigaribaldi0@gmail.com