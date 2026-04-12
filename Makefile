# Variables
APP_NAME=apimetro
MAIN_PATH=./cmd/main.go
DOCS_DIR=./cmd/docs
GOBIN=$(HOME)/go/bin

.PHONY: all build dev docs clean

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