# Variables
APP_NAME=apimetro
MAIN_PATH=./cmd/main.go
DOCS_DIR=./cmd/docs
GOBIN=$(HOME)/go/bin

# Directorio de archivos .env (fuera del repo para no exponer credenciales)
# Sobreescribir con: make docker-dev SECRETS_DIR=/ruta/alternativa
SECRETS_DIR ?= $(HOME)/.SecretsFiles

.PHONY: all build dev docs clean docker-dev docker-qa docker-main db-sync \
       plutarco-setup plutarco-status plutarco-etl plutarco-etl-all \
       docker-dev-scenario-mb docker-dev-scenario-metro \
       docker-down-scenario-mb docker-down-scenario-metro \
       docker-all docker-down-all wait-for-init verify-integrity \
       logs logs-dev logs-mb logs-metro \
       anillar-status anillar-cleanup help-anillar

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
	chmod +x db/init/03_roles.sh
	docker compose --profile dev --env-file $(SECRETS_DIR)/.env.dev up --build

docker-qa: docs
	@echo "Levantando entorno QA (API :8081 | DB :5434)..."
	chmod +x db/init/03_roles.sh
	docker compose --profile qa --env-file $(SECRETS_DIR)/.env.qa up --build

docker-main: docs
	@echo "Levantando entorno MAIN (API :8082 | DB :5435)..."
	chmod +x db/init/03_roles.sh
	docker compose --profile main --env-file $(SECRETS_DIR)/.env.main up --build -d

# Bajar contenedores de un entorno específico
docker-down-dev:
	docker compose --profile dev --env-file $(SECRETS_DIR)/.env.dev down

docker-down-qa:
	docker compose --profile qa --env-file $(SECRETS_DIR)/.env.qa down

docker-down-main:
	docker compose --profile main --env-file $(SECRETS_DIR)/.env.main down

# ==========================================
# Escenarios Anillo Periférico — Entornos aislados para VFTModel
# ==========================================

docker-dev-scenario-mb: docs
	@echo "Levantando escenario MB — Red real + Anillo Periférico como BRT (API :8083 | DB :5436)..."
	@echo "La migración del anillo se carga automáticamente al inicializar la DB."
	chmod +x db/init/03_roles.sh
	docker compose --profile scenario-mb --env-file $(SECRETS_DIR)/.env.dev up --build

docker-dev-scenario-metro: docs
	@echo "Levantando escenario METRO — Red real + Anillo Periférico como Metro (API :8084 | DB :5437)..."
	@echo "La migración del anillo se carga automáticamente al inicializar la DB."
	chmod +x db/init/03_roles.sh
	docker compose --profile scenario-metro --env-file $(SECRETS_DIR)/.env.dev up --build

docker-down-scenario-mb:
	docker compose --profile scenario-mb --env-file $(SECRETS_DIR)/.env.dev down -v

docker-down-scenario-metro:
	docker compose --profile scenario-metro --env-file $(SECRETS_DIR)/.env.dev down -v

# Bajar y destruir volúmenes de los 3 entornos de análisis
docker-down-all:
	docker compose --profile dev          --env-file $(SECRETS_DIR)/.env.dev down -v
	docker compose --profile scenario-mb  --env-file $(SECRETS_DIR)/.env.dev down -v
	docker compose --profile scenario-metro --env-file $(SECRETS_DIR)/.env.dev down -v
	@echo "Todos los entornos y volúmenes eliminados."

# Espera a que el init de los 3 contenedores de DB esté completo.
# El init termina cuando plutarco.agebs tiene datos (seed_plutarco.sql es el último script).
wait-for-init:
	@echo "Esperando init completo (seed_plutarco puede tardar 8-10 min)..."
	@PGUSER=$$(grep ^POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2); \
	 PGDB=$$(grep ^DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2); \
	 for CT in apimetro_db_dev apimetro_db_scenario_mb apimetro_db_scenario_metro; do \
	   printf "  Esperando $$CT..."; \
	   until docker exec $$CT psql -U $$PGUSER -d $$PGDB -tAc \
	     "SELECT COUNT(*) FROM plutarco.agebs" 2>/dev/null | grep -q "^[1-9]"; do \
	     sleep 5; printf "."; \
	   done; \
	   echo " listo"; \
	 done

# ETL de afluencia para todos los entornos activos (DEV + MB + METRO)
# Cada llamada usa (cd ETL && ...) para que el cd no persista entre iteraciones del loop.
plutarco-etl-all:
	@echo "=== ETL Plutarco — DEV :5433, MB :5436, METRO :5437 ==="
	@PGUSER=$$(grep ^POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2); \
	 PGPASS=$$(grep ^POSTGRES_PASSWORD $(SECRETS_DIR)/.env.dev | cut -d= -f2); \
	 PGDB=$$(grep ^DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2); \
	 for PORT in 5433 5436 5437; do \
	   echo "  [$$PORT] LoadAfluencia..."; \
	   (cd ETL && DB_HOST=127.0.0.1 DB_PORT=$$PORT \
	     DB_USER=$$PGUSER DB_PASSWORD=$$PGPASS DB_NAME=$$PGDB \
	     python3 -c "from DataCharge import LoadAfluencia; LoadAfluencia.run()"); \
	   echo "  [$$PORT] LoadAfluenciaEstacion..."; \
	   (cd ETL && DB_HOST=127.0.0.1 DB_PORT=$$PORT \
	     DB_USER=$$PGUSER DB_PASSWORD=$$PGPASS DB_NAME=$$PGDB \
	     python3 -c "from DataCharge import LoadAfluenciaEstacion; LoadAfluenciaEstacion.run()"); \
	 done
	@echo "ETL completado en los 3 entornos."

# Levantar los 3 entornos en background + esperar init + cargar ETL
# Equivalente a: docker-down-all + docker-dev (x3) + wait-for-init + plutarco-etl-all
docker-all: docs
	@echo "Levantando los 3 entornos en background..."
	chmod +x db/init/03_roles.sh db/init/05_apply_anillar.sh
	docker compose --profile dev           --env-file $(SECRETS_DIR)/.env.dev up --build -d
	docker compose --profile scenario-mb   --env-file $(SECRETS_DIR)/.env.dev up --build -d
	docker compose --profile scenario-metro --env-file $(SECRETS_DIR)/.env.dev up --build -d
	$(MAKE) wait-for-init
	$(MAKE) plutarco-etl-all
	@echo ""
	@echo "✓ Los 3 entornos están listos con datos completos."
	@echo "  DEV   :8080  MB :8083  METRO :8084"
	@echo "  Verifica: make verify-integrity"

# Queries de integridad — valida que los 3 entornos tienen datos correctos y diferenciados
verify-integrity:
	@echo "======================================================"
	@echo "  Apimetro — Verificación de integridad de entornos"
	@echo "======================================================"
	@PGUSER=$$(grep ^POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2); \
	 PGDB=$$(grep ^DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2); \
	 echo ""; \
	 echo "--- 1. Conteos públicos (red de transporte) ---"; \
	 for CT in apimetro_db_dev apimetro_db_scenario_mb apimetro_db_scenario_metro; do \
	   echo "  $$CT:"; \
	   docker exec $$CT psql -U $$PGUSER -d $$PGDB -tA -c \
	     "SELECT '    lineas='||COUNT(*)||' ramals='||(SELECT COUNT(*) FROM ramals)||' estacions='||(SELECT COUNT(*) FROM estacions)||' seq='||(SELECT last_value FROM ramals_id_seq) FROM lineas"; \
	 done; \
	 echo ""; \
	 echo "--- 2. Anillo periférico (solo en escenarios) ---"; \
	 for CT in apimetro_db_scenario_mb apimetro_db_scenario_metro; do \
	   echo "  $$CT:"; \
	   docker exec $$CT psql -U $$PGUSER -d $$PGDB -tA -c \
	     "SELECT '    lineas_anillo='||COUNT(*) FROM lineas WHERE clasificacion='propuesta_periferico'"; \
	   docker exec $$CT psql -U $$PGUSER -d $$PGDB -tA -c \
	     "SELECT '    ramals_anillo='||COUNT(*) FROM ramals WHERE linea_id BETWEEN 2071 AND 3074"; \
	   docker exec $$CT psql -U $$PGUSER -d $$PGDB -tA -c \
	     "SELECT '    estacs_anillo='||COUNT(*) FROM estacions WHERE id BETWEEN 31001 AND 32200"; \
	 done; \
	 echo ""; \
	 echo "--- 3. Plutarco (geo + ETL) ---"; \
	 for CT in apimetro_db_dev apimetro_db_scenario_mb apimetro_db_scenario_metro; do \
	   echo "  $$CT:"; \
	   docker exec $$CT psql -U $$PGUSER -d $$PGDB -tA -c \
	     "SELECT '    agebs='||COUNT(*) FROM plutarco.agebs"; \
	   docker exec $$CT psql -U $$PGUSER -d $$PGDB -tA -c \
	     "SELECT '    catalogo='||COUNT(*) FROM plutarco.catalogo_homologacion"; \
	   docker exec $$CT psql -U $$PGUSER -d $$PGDB -tA -c \
	     "SELECT '    afluencia_linea='||COUNT(*) FROM plutarco.afluencia_linea"; \
	   docker exec $$CT psql -U $$PGUSER -d $$PGDB -tA -c \
	     "SELECT '    afluencia_estacion='||COUNT(*) FROM plutarco.afluencia_estacion"; \
	 done; \
	 echo ""; \
	 echo "--- 4. GeoJSON endpoints ---"; \
	 for PORT in 8080 8083 8084; do \
	   L=$$(curl -s "http://localhost:$$PORT/movilidad/mapas/geojsonLinea" | python3 -c "import sys,json; print(len(json.load(sys.stdin)['features']))" 2>/dev/null); \
	   E=$$(curl -s "http://localhost:$$PORT/movilidad/mapas/geojsonEstacion" | python3 -c "import sys,json; print(len(json.load(sys.stdin)['features']))" 2>/dev/null); \
	   A=$$(curl -s "http://localhost:$$PORT/movilidad/analitico/afluencia-estacion?limit=1" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('total','BLOQUEADO'))" 2>/dev/null); \
	   echo "  :$$PORT  lineas=$$L  estaciones=$$E  afluencia_total=$$A"; \
	 done; \
	 echo ""; \
	 echo "--- 5. Diferenciación entre escenarios ---"; \
	 DEV_L=$$(docker exec apimetro_db_dev psql -U $$PGUSER -d $$PGDB -tAc "SELECT COUNT(*) FROM lineas"); \
	 MB_L=$$(docker exec apimetro_db_scenario_mb psql -U $$PGUSER -d $$PGDB -tAc "SELECT COUNT(*) FROM lineas"); \
	 if [ "$$DEV_L" = "$$MB_L" ]; then echo "  [FAIL] DEV y MB tienen el mismo nro de líneas — anillo no cargó"; \
	 else echo "  [OK] DEV=$$DEV_L lineas  MB=$$MB_L lineas  (diferencia esperada: +4)"; fi; \
	 echo "======================================================"

# ==========================================
# Logs — Seguimiento de contenedores en vivo
# ==========================================

# Un solo stream con los 3 entornos (prefijo de color por contenedor)
logs:
	docker compose \
	  --profile dev --profile scenario-mb --profile scenario-metro \
	  --env-file $(SECRETS_DIR)/.env.dev \
	  logs -f --tail=50

# Por entorno individual (para terminales separadas)
logs-dev:
	docker compose --profile dev --env-file $(SECRETS_DIR)/.env.dev logs -f --tail=50

logs-mb:
	docker compose --profile scenario-mb --env-file $(SECRETS_DIR)/.env.dev logs -f --tail=50

logs-metro:
	docker compose --profile scenario-metro --env-file $(SECRETS_DIR)/.env.dev logs -f --tail=50

# Verificar estado de datos del anillo en un contenedor
CONTAINER ?= apimetro_db_scenario_mb
anillar-status:
	@echo "=== Estado del Anillo Periférico Interior ==="
	@docker exec $(CONTAINER) psql -U $$(grep POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-d $$(grep DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-c "SELECT 'lineas' AS tabla, count(*) FROM lineas WHERE clasificacion = 'propuesta_periferico' \
		    UNION ALL SELECT 'estacions', count(*) FROM estacions WHERE id BETWEEN 31001 AND 32200 \
		    UNION ALL SELECT 'ramals', count(*) FROM ramals WHERE linea_id BETWEEN 2071 AND 3074 \
		    UNION ALL SELECT 'historico_op', count(*) FROM historico_operacion WHERE linea_id BETWEEN 2071 AND 3074;"

# Guía completa de la propuesta Anillo Periférico Interior
help-anillar:
	@echo ""
	@echo "============================================================"
	@echo "  Anillo Periférico Interior — Guía de entornos (VFTModel)"
	@echo "============================================================"
	@echo ""
	@echo "PUERTOS"
	@echo "  DEV (red real)     API :8080  DB :5433"
	@echo "  Scenario MB        API :8083  DB :5436"
	@echo "  Scenario METRO     API :8084  DB :5437"
	@echo ""
	@echo "IDs DEL ANILLO (no modificar)"
	@echo "  MB    linea_id 2071-2074  estacion_id 31001-31098"
	@echo "  METRO linea_id 3071-3074  estacion_id 32001-32098"
	@echo "  (estacion_id_oficial es SMALLINT, max 32767 — no usar IDs mayores)"
	@echo ""
	@echo "LEVANTAR ENTORNOS"
	@echo "  make docker-dev                 Red real (caso base)"
	@echo "  make docker-dev-scenario-mb     Red + Anillo como BRT"
	@echo "  make docker-dev-scenario-metro  Red + Anillo como Metro"
	@echo ""
	@echo "VERIFICAR DATOS DEL ANILLO"
	@echo "  make anillar-status CONTAINER=apimetro_db_scenario_mb"
	@echo "  make anillar-status CONTAINER=apimetro_db_scenario_metro"
	@echo ""
	@echo "REINICIAR DESDE CERO (destruye volúmenes y recarga todo, incluye ETL)"
	@echo "  make docker-down-all && make docker-all"
	@echo "  (automatiza: init → anillo → catálogo → seed_plutarco → ETL afluencia)"
	@echo ""
	@echo "VERIFICAR INTEGRIDAD (tras reconstruir)"
	@echo "  make verify-integrity"
	@echo ""
	@echo "APLICAR MIGRACIÓN A CONTENEDOR YA CORRIENDO (sin recrear)"
	@echo "  docker exec apimetro_db_scenario_mb bash -c \\"
	@echo "    'psql -v ON_ERROR_STOP=1 -U \"\$$POSTGRES_USER\" -d \"\$$POSTGRES_DB\" -f /migrations/v4.0_anillar_mb.sql'"
	@echo "  docker exec apimetro_db_scenario_metro bash -c \\"
	@echo "    'psql -v ON_ERROR_STOP=1 -U \"\$$POSTGRES_USER\" -d \"\$$POSTGRES_DB\" -f /migrations/v4.0_anillar_metro.sql'"
	@echo "  (seguro re-ejecutar — lineas usan ON CONFLICT DO NOTHING)"
	@echo ""
	@echo "LIMPIAR DATOS DEL ANILLO SIN DESTRUIR VOLUMEN"
	@echo "  make anillar-cleanup CONTAINER=apimetro_db_scenario_mb"
	@echo "  make anillar-cleanup CONTAINER=apimetro_db_scenario_metro"
	@echo ""
	@echo "PROBLEMAS CONOCIDOS Y SOLUCIONES"
	@echo "  [1] Error 'smallint out of range'"
	@echo "      estacion_id_oficial es SMALLINT (max 32767)."
	@echo "      IDs en los archivos de migracion deben estar en 31001-32098."
	@echo ""
	@echo "  [2] Error 'chk_coords_consistency'"
	@echo "      Estaciones RTP tienen geom pero lon/lat NULL (seed antiguo)."
	@echo "      Constraint ya relajada en 01_init.sql — solo requiere lon+lat."
	@echo ""
	@echo "  [3] Error 'mountpoint outside of rootfs'"
	@echo "      No se puede montar un archivo sobre un directorio en Docker."
	@echo "      Solucion: usar 05_apply_anillar.sh + /migrations separado."
	@echo ""
	@echo "  [4] Init no re-corre en volumen existente"
	@echo "      PostgreSQL solo ejecuta docker-entrypoint-initdb.d en volumen vacio."
	@echo "      Si el volumen ya existe, usar 'APLICAR MIGRACIÓN' arriba."
	@echo ""
	@echo "  [5] Error en seed (linea 5: backslash-restrict)"
	@echo "      El dump original tiene un watermark invalido en psql."
	@echo "      Solucion: ya removido de 04_seed.sql — no editar."
	@echo ""
	@echo "RAMA: feat/propuesta-anillar (NO mergear a DEV ni main)"
	@echo "NOTAS: docs/NOTAS_REPLICABILIDAD_PROPUESTA.md"
	@echo "============================================================"
	@echo ""

# Limpiar datos del anillo de un contenedor
anillar-cleanup:
	@echo "=== Limpiando datos del Anillo Periférico Interior ==="
	docker cp scripts/anillar_cleanup.sql $(CONTAINER):/tmp/anillar_cleanup.sql
	docker exec $(CONTAINER) psql -U $$(grep POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-d $$(grep DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		-f /tmp/anillar_cleanup.sql

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
		> db/init/01_init.sql
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

# Ejecutar ETLs de plutarco solo para DEV (puerto 5433)
# Para cargar todos los entornos usar: make plutarco-etl-all
plutarco-etl:
	@echo "=== Ejecutando ETL de extensión Plutarco (DEV :5433) ==="
	@echo "Requiere: CSVs en ETL/Data/Pesos/"
	@echo ""
	cd ETL && DB_HOST=127.0.0.1 DB_PORT=5433 \
		DB_USER=$$(grep ^POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		DB_PASSWORD=$$(grep ^POSTGRES_PASSWORD $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		DB_NAME=$$(grep ^DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		python3 -c "from DataCharge import LoadAfluencia; LoadAfluencia.run()"
	@echo ""
	cd ETL && DB_HOST=127.0.0.1 DB_PORT=5433 \
		DB_USER=$$(grep ^POSTGRES_USER $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		DB_PASSWORD=$$(grep ^POSTGRES_PASSWORD $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		DB_NAME=$$(grep ^DB_NAME $(SECRETS_DIR)/.env.dev | cut -d= -f2) \
		python3 -c "from DataCharge import LoadAfluenciaEstacion; LoadAfluenciaEstacion.run()"
	@echo ""
	@echo "ETL completado. Verifica con: make plutarco-status"

# Setup completo: dependencias + ETL en todos los entornos activos
# Nota: desde el init automático 06_seed_catalogo.sql corre en Docker init,
# por lo que el catálogo ya debería estar cargado al llegar aquí.
plutarco-setup: plutarco-deps plutarco-etl-all
	@echo ""
	@echo "✓ Extensión Plutarco activada en DEV, MB y METRO."
	@echo "  Verifica: make verify-integrity"