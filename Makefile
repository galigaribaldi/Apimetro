# Variables
APP_NAME=apimetro
MAIN_PATH=./cmd/main.go
DOCS_DIR=./cmd/docs
GOBIN=$(HOME)/go/bin

.PHONY: all build dev docs clean docker-dev docker-qa docker-main db-sync

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
	docker compose --profile dev --env-file .env.dev up --build

docker-qa: docs
	@echo "Levantando entorno QA (API :8081 | DB :5434)..."
	chmod +x db/init/roles.sh
	docker compose --profile qa --env-file .env.qa up --build

docker-main: docs
	@echo "Levantando entorno MAIN (API :8082 | DB :5435)..."
	chmod +x db/init/roles.sh
	docker compose --profile main --env-file .env.main up --build -d

# Bajar contenedores de un entorno específico
docker-down-dev:
	docker compose --profile dev --env-file .env.dev down

docker-down-qa:
	docker compose --profile qa --env-file .env.qa down

docker-down-main:
	docker compose --profile main --env-file .env.main down

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