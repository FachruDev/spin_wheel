#!/usr/bin/env bash
# Membuat deploy/.env dari .env.example lalu mengisi semua rahasia yang masih kosong dengan
# nilai acak. Aman dijalankan ulang: nilai yang sudah terisi tidak pernah diubah.
#
# Pakai: bash scripts/init-env.sh
set -euo pipefail

cd "$(dirname "$0")/.."
if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Dibuat: deploy/.env"
fi
chmod 600 .env

random_secret() {
  # Hanya huruf dan angka: aman untuk sed, YAML, dan URL.
  openssl rand -base64 96 | tr -dc 'A-Za-z0-9' | head -c 64
}

for key in DB_PASSWORD SERVICE_SECRET EMAIL_SECRET_HASH_PEPPER JWT_REFRESH_TOKEN_HASH_PEPPER JWT_HMAC_SHA512_PRIVATE_KEY; do
  if grep -qE "^${key}=$" .env; then
    sed -i "s|^${key}=$|${key}=$(random_secret)|" .env
    echo "Diisi acak: $key"
  fi
done

todo=()
for key in APP_DOMAIN API_DOMAIN CERTBOT_EMAIL SMTP_HOST SMTP_USERNAME SMTP_PASSWORD SMTP_FROM; do
  value="$(grep -E "^${key}=" .env | cut -d= -f2- || true)"
  if [[ -z "$value" || "$value" == *contoh.co.id* ]]; then
    todo+=("$key")
  fi
done

if ((${#todo[@]})); then
  echo
  echo "Masih perlu diisi manual di deploy/.env:"
  printf '  - %s\n' "${todo[@]}"
  echo "Lalu lanjutkan dengan: bash scripts/init-cert.sh"
else
  echo "deploy/.env lengkap. Lanjutkan dengan: bash scripts/init-cert.sh"
fi
