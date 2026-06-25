# ---- Etapa 1: Constructor (Builder) ----
FROM golang:1.26-alpine AS builder

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos los archivos de dependencias y las descargamos
COPY go.mod go.sum ./
RUN go mod download

# Copiamos todo el código fuente de tu proyecto
COPY . .

# Compilamos la aplicación estáticamente
# CGO_ENABLED=0 garantiza que el binario funcione perfecto en la etapa 2
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/bin/apimetro ./cmd/main.go

# ---- Etapa 2: Producción (Runner) ----
FROM alpine:latest

WORKDIR /root/

# Instalamos certificados de seguridad (útil si tu API consulta links externos) y zonas horarias
RUN apk --no-cache add ca-certificates tzdata

# Copiamos ÚNICAMENTE el binario desde la Etapa 1, dejando atrás todo el código fuente
COPY --from=builder /app/bin/apimetro .

# Exponemos el puerto de la API
EXPOSE 8080

# Comando para ejecutar el servidor
CMD ["./apimetro"]