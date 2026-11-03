#!/usr/bin/env bash
# Mengambil sertifikat HTTPS pertama kali untuk APP_DOMAIN dan API_DOMAIN.
# Jalankan sekali sebelum `docker compose up`; perpanjangan berikutnya otomatis oleh container certbot.
set -euo pipefail

cd "$(dirname "$0")/.."
set -a
# shellcheck disable=SC1091
source .env
set +a
: "${APP_DOMAIN:?isi APP_DOMAIN di .env}" "${API_DOMAIN:?isi API_DOMAIN di .env}" "${CERTBOT_EMAIL:?isi CERTBOT_EMAIL di .env}"

# Port 80 harus kosong selama verifikasi.
docker compose stop web 2>/dev/null || true
docker compose run --rm -p 80:80 --entrypoint certbot certbot certonly --standalone \
  -d "$APP_DOMAIN" -d "$API_DOMAIN" \
  --email "$CERTBOT_EMAIL" --agree-tos --no-eff-email
echo "Sertifikat tersimpan di deploy/certbot/conf/live/$APP_DOMAIN/"
