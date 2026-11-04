#!/usr/bin/env bash
# Cek cepat setelah deploy: status container, API menjawab, dan aplikasi web bisa dibuka.
#
# Pakai: bash scripts/check.sh
# Untuk uji lokal dengan sertifikat buatan sendiri:
#   CHECK_RESOLVE_IP=127.0.0.1 CHECK_PORT=8443 CHECK_INSECURE=1 bash scripts/check.sh
set -euo pipefail

cd "$(dirname "$0")/.."
set -a
# shellcheck disable=SC1091
source "${ENV_FILE:-.env}"
set +a

port="${CHECK_PORT:-443}"
curl_args=(--silent --output /dev/null --write-out '%{http_code}' --max-time 10)
if [[ -n "${CHECK_RESOLVE_IP:-}" ]]; then
  curl_args+=(--resolve "${APP_DOMAIN}:${port}:${CHECK_RESOLVE_IP}" --resolve "${API_DOMAIN}:${port}:${CHECK_RESOLVE_IP}")
fi
[[ -n "${CHECK_INSECURE:-}" ]] && curl_args+=(--insecure)

docker compose ps

# Endpoint yang butuh login: 401 berarti server berjalan dan terhubung lewat nginx.
api=""
for _ in $(seq 1 30); do
  api="$(curl "${curl_args[@]}" -X POST -H 'Content-Type: application/json' -d '{}' \
    "https://${API_DOMAIN}:${port}/organization/mine" || true)"
  [[ "$api" == "401" ]] && break
  sleep 2
done
web="$(curl "${curl_args[@]}" "https://${APP_DOMAIN}:${port}/" || true)"

echo
echo "API  https://${API_DOMAIN}  -> HTTP $api (harus 401)"
echo "Web  https://${APP_DOMAIN}  -> HTTP $web (harus 200)"
if [[ "$api" == "401" && "$web" == "200" ]]; then
  echo "OK: aplikasi siap dipakai."
else
  echo "Ada yang belum beres. Lihat log: docker compose logs --tail 100 server web" >&2
  exit 1
fi
