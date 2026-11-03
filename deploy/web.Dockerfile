# Membangun aplikasi Flutter web lalu menyajikannya dengan nginx.
# Build dari root repo: docker build -f deploy/web.Dockerfile --build-arg SERVER_URL=https://api.contoh.id/ .

ARG FLUTTER_VERSION=3.41.6

FROM ghcr.io/cirruslabs/flutter:${FLUTTER_VERSION} AS build
WORKDIR /app
COPY pubspec.lock .
COPY undian_core undian_core
COPY undian_client undian_client
COPY undian_flutter undian_flutter
# Workspace kecil tanpa server, dengan versi dependency dari pubspec.lock.
RUN printf '%s\n' \
  'name: _' \
  'environment:' \
  '  sdk: ^3.8.0' \
  'workspace:' \
  '  - undian_core' \
  '  - undian_client' \
  '  - undian_flutter' \
  > pubspec.yaml

WORKDIR /app/undian_flutter
ARG SERVER_URL
RUN flutter pub get && flutter build web --release --dart-define=SERVER_URL=${SERVER_URL}

FROM nginx:1.27-alpine
COPY --from=build /app/undian_flutter/build/web /usr/share/nginx/html
# File di templates/ diproses envsubst saat container start (${APP_DOMAIN}, ${API_DOMAIN}).
COPY deploy/nginx/templates /etc/nginx/templates
