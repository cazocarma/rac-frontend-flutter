FROM ghcr.io/cirruslabs/flutter:3.44.0 AS builder
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release
FROM nginx:1.28-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY docker/config.json.template /etc/rac-config.json.template
COPY docker/40-runtime-config.sh /docker-entrypoint.d/40-runtime-config.sh
RUN chmod +x /docker-entrypoint.d/40-runtime-config.sh
EXPOSE 80
