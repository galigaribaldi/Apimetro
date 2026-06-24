# Variables
APP_NAME=apimetro
MAIN_PATH=./cmd/main.go
DOCS_DIR=./cmd/docs
GOBIN=$(HOME)/go/bin

# Directorio de archivos .env (fuera del repo para no exponer credenciales)
# Sobreescribir con: make docker-dev SECRETS_DIR=/ruta/alternativa
SECRETS_DIR ?= $(HOME)/.SecretsFiles

.PHONY: all build dev docs clean docker-dev docker-qa docker-main db-sync \
       plutarco-setup plutarco-status plutarco-etl

all: dev

# Generar documentación de Swagger
docs:
	@echo "Actualizando documentación de Swagger..."
	$(GOBIN)/swag init -g main.go -d ./cmd -o $(DOCS_DIR) --parseDependency --parseInternal

# Correr el servidor con Air (Live Reload) y actualizar docs al inicio
dev: docs
	@echo "Iniciando servidor con Air..."
	$(GOBIN)/air

# Compilar el binario
build: docs
	@echo "Compilando binario..."
	go build -o bin/$(APP_NAME) $(MAIN_PATH)

# Limpiar archivos temporales y binarios
clean:
	@echo "Limpiando..."
	rm -rf bin/
	rm -rf tmp/
	rm -rf $(DOCS_DIR)

# ==========================================
# Docker — Levantar entornos
# ==========================================

# Asegura que roles.sh sea ejecutable antes de montar en Docker
docker-dev: docs
	@echo "Levantando entorno DEV (API :8080 | DB :5433)..."
	chmod +x db/init/roles.sh
	docker compose --profile dev --env-file $(SECRETS_DIR)/.env.dev up --build

docker-qa: docs
	@echo "Levantando entorno QA (API :8081 | DB :5434)..."
	chmod +x db/init/roles.sh
	docker compose --profile qa --env-file $(SECRETS_DIR)/.env.qa up --build

docker-main: docs
	@echo "Levantando entorno MAIN (API :8082 | DB :5435)..."
	chmod +x db/init/roles.sh
	docker compose --profile main --env-file $(SECRETS_DIR)/.env.main up --build -d

# Bajar contenedores de un entorno específico
docker-down-dev:
	docker compose --profile dev --env-file $(SECRETS_DIR)/.env.dev down

docker-down-qa:
	docker compose --profile qa --env-file $(SECRETS_DIR)/.env.qa down

docker-down-main:
	docker compose --profile main --env-file $(SECRETS_DIR)/.env.main down

# ==========================================
# db-sync — Exportar esquema de la DB local a init.sql
# Útil para mantener init.sql sincronizado con cambios manuales en la DB.
# ADVERTENCIA: sobreescribe db/init/init.sql — revisar antes de usar con Docker.
# ==========================================
db-sync:
	@echo "Exportando esquema desde PostgreSQL local..."
	pg_dump --schema-only --no-owner --no-acl \
		--exclude-table=estaciones_backup \
		--exclude-table=lineas_backup \
		--exclude-table=ramales_backup \
		--exclude-table=spatial_ref_sys \
		-h localhost -p 5432 -U prueba db_apimetro \
		> db/init/init.sql
	@echo "init.sql actualizado. Revisa y ajusta el archivo antes de usarlo con Docker."

# ==========================================
# Extensión Plutarco — Setup y ETL
# ==========================================

# Verificar estado de la extensión plutarco
plutarco-status:
	@echo "=== Estado de extensión Plutarco ==="
	@echo ""
	@echo "Verificando conexión a DB (puerto 5433)..."
	@docker exec apimetro_db_dev psql -U $$(grep POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-d $$(grep DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-c "SELECT tablename, (SELECT COUNT(*) FROM plutarco.\"\$$1\" ) FROM (VALUES ('agebs'),('afluencia_linea'),('afluencia_estacion'),('calles'),('uso_suelo'),('curvas_nivel'),('catalogo_homologacion')) AS t(tablename);" 2>/dev/null \
		|| (echo ""; echo "Alternativa — conteo por tabla:"; \
		    docker exec apimetro_db_dev psql -U $$(grep POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
			-d $$(grep DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
			-c "SELECT 'agebs' AS tabla, COUNT(*) FROM plutarco.agebs UNION ALL SELECT 'afluencia_linea', COUNT(*) FROM plutarco.afluencia_linea UNION ALL SELECT 'afluencia_estacion', COUNT(*) FROM plutarco.afluencia_estacion UNION ALL SELECT 'catalogo_homologacion', COUNT(*) FROM plutarco.catalogo_homologacion;")
	@echo ""
	@echo "Si las tablas tienen 0 registros, ejecuta: make plutarco-setup"

# Instalar dependencias Python para ETL
plutarco-deps:
	@echo "Instalando dependencias Python para ETL..."
	pip install -r ETL/requirements.txt

# Ejecutar ETLs de plutarco (requiere CSVs en ETL/Data/)
plutarco-etl:
	@echo "=== Ejecutando ETL de extensión Plutarco ==="
	@echo "Requiere: CSVs en ETL/Data/Pesos/ y shapefiles en ETL/Data/AGEBS/"
	@echo "Conectando a DB en localhost:5433..."
	@echo ""
	cd ETL && DB_HOST=localhost DB_PORT=5433 DB_USER=prueba DB_PASSWORD=postgres DB_NAME=db_apimetro \
		python3 -c "from DataCharge import LoadAfluencia; LoadAfluencia.run()"
	@echo ""
	cd ETL && DB_HOST=localhost DB_PORT=5433 DB_USER=prueba DB_PASSWORD=postgres DB_NAME=db_apimetro \
		python3 -c "from DataCharge import LoadAfluenciaEstacion; LoadAfluenciaEstacion.run()"
	@echo ""
	@echo "ETL completado. Verifica con: make plutarco-status"

# Setup completo: dependencias + migración + ETL
plutarco-setup: plutarco-deps
	@echo ""
	@echo "=== Aplicando migraciones plutarco ==="
	docker exec apimetro_db_dev psql -U $$(grep POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-d $$(grep DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-f /docker-entrypoint-initdb.d/init_plutarco.sql
	@echo ""
	@echo "=== Cargando seed del catálogo de homologación ==="
	docker cp db/migrations/seed_catalogo_homologacion.sql apimetro_db_dev:/tmp/seed_cat.sql
	docker exec apimetro_db_dev psql -U $$(grep POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-d $$(grep DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-f /tmp/seed_cat.sql
	@echo ""
	@echo "=== Ejecutando ETL ==="
	$(MAKE) plutarco-etl
	@echo ""
	@echo "✓ Extensión Plutarco activada. Reinicia la API para verificar:"
	@echo "  curl http://localhost:8080/movilidad/analitico/afluencia-estacion"