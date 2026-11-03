#!/usr/bin/env bash
# Memulihkan database undian dari file backup buatan backup.sh.
# PERHATIAN: seluruh isi database saat ini akan diganti dengan isi backup.
#
# Pakai: deploy/scripts/restore.sh deploy/backups/undian-20261103-021500.sql.gz
set -euo pipefail

if [[ $# -ne 1 || ! -f "$1" ]]; then
  echo "Pakai: $0 <file-backup.sql.gz>" >&2
  exit 1
fi
source_file="$(realpath "$1")"

read -r -p "Database 'undian' akan DITIMPA dari $(basename "$source_file"). Ketik YA untuk lanjut: " answer
if [[ "$answer" != "YA" ]]; then
  echo "Dibatalkan."
  exit 1
fi

cd "$(dirname "$0")/.."
docker compose stop server
docker compose exec -T postgres psql -U postgres -v ON_ERROR_STOP=1 \
  -c 'DROP DATABASE IF EXISTS undian WITH (FORCE);' \
  -c 'CREATE DATABASE undian;'
gunzip -c "$source_file" | docker compose exec -T postgres psql -U postgres -d undian -v ON_ERROR_STOP=1 -q
docker compose start server
echo "Pemulihan selesai dari $(basename "$source_file")."
