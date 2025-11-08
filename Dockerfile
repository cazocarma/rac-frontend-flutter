# Etapa 1: Compilar Flutter Web
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS builder

WORKDIR /app
RUN apt-get update && apt-get install -y git curl unzip xz-utils libglu1-mesa && rm -rf /var/lib/apt/lists/*

# Build args opcionales para --dart-define
ARG API_BASE_URL
ARG KEYCLOAK_PUBLIC_URL

# Copiar proyecto
COPY . .

# Habilitar web y deps
RUN flutter config --enable-web
RUN if [ ! -f "pubspec.yaml" ]; then flutter create .; fi
RUN flutter pub get

# Compilar (usa defines si se entregan; si no, compila con defaults del código)
RUN if [ -n "$API_BASE_URL" ] || [ -n "$KEYCLOAK_PUBLIC_URL" ]; then \
      flutter build web --release \
        $( [ -n "$API_BASE_URL" ] && echo --dart-define=API_BASE_URL=$API_BASE_URL ) \
        $( [ -n "$KEYCLOAK_PUBLIC_URL" ] && echo --dart-define=KEYCLOAK_PUBLIC_URL=$KEYCLOAK_PUBLIC_URL ); \
    else \
      flutter build web --release; \
    fi

# Etapa 2: Servir con NGINX
FROM nginx:1.25-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]
