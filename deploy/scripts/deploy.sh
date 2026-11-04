#!/usr/bin/env bash
# Menjalankan atau memperbarui aplikasi di VPS: ambil kode terbaru, build, jalankan, lalu cek.
# Migrasi database diterapkan otomatis saat container server start.
#
# Pakai: bash scripts/deploy.sh            (dengan git pull)
#        bash scripts/deploy.sh --no-pull  (pakai kode yang ada)
set -euo pipefail

cd "$(dirname "$0")/.."
if [[ ! -f .env ]]; then
  echo "deploy/.env belum ada. Jalankan dulu: bash scripts/init-env.sh" >&2
  exit 1
fi
set -a
# shellcheck disable=SC1091
source .env
set +a
if [[ ! -f "certbot/conf/live/${APP_DOMAIN}/fullchain.pem" ]]; then
  echo "Sertifikat HTTPS untuk ${APP_DOMAIN} belum ada. Jalankan dulu: bash scripts/init-cert.sh" >&2
  exit 1
fi

if [[ "${1:-}" != "--no-pull" ]]; then
  git -C .. pull --ff-only
fi

# Backup sebelum memperbarui, kalau database sudah pernah berjalan.
if docker compose ps --status running --services 2>/dev/null | grep -qx postgres; then
  bash scripts/backup.sh
fi

docker compose up -d --build --remove-orphans
docker image prune -f >/dev/null
bash scripts/check.sh
