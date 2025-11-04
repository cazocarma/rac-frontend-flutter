# Etapa 1: Compilar Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS builder

WORKDIR /app

# Instalar dependencias necesarias del sistema
RUN apt-get update && apt-get install -y git curl unzip xz-utils libglu1-mesa && rm -rf /var/lib/apt/lists/*

# Copiar proyecto Flutter
COPY . .

# Habilitar soporte Web
RUN flutter config --enable-web

# Verificar si pubspec.yaml existe (para builds vacíos)
RUN if [ ! -f "pubspec.yaml" ]; then flutter create .; fi

# Descargar dependencias antes de compilar
RUN flutter pub get

# Compilar el proyecto
RUN flutter build web --release

# Etapa 2: Servir con NGINX
FROM nginx:1.25-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
