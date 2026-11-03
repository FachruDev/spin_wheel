#!/usr/bin/env bash
# Backup database undian ke deploy/backups/ dan hapus backup yang lebih tua dari KEEP_DAYS.
#
# Contoh cron di VPS (tiap hari jam 02:15):
#   15 2 * * * bash /opt/undian/deploy/scripts/backup.sh >> /var/log/undian-backup.log 2>&1
set -euo pipefail

cd "$(dirname "$0")/.."
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi

backup_dir="${BACKUP_DIR:-./backups}"
keep_days="${KEEP_DAYS:-14}"
mkdir -p "$backup_dir"

file="$backup_dir/undian-$(date +%Y%m%d-%H%M%S).sql.gz"
docker compose exec -T postgres pg_dump -U postgres -d undian --no-owner | gzip > "$file.tmp"
mv "$file.tmp" "$file"
echo "$(date -Is) backup selesai: $file ($(du -h "$file" | cut -f1))"

find "$backup_dir" -name 'undian-*.sql.gz' -mtime +"$keep_days" -delete

# Salinan di luar VPS, supaya data aman walau VPS rusak.
if [[ -n "${OFFSITE_TARGET:-}" ]]; then
  rsync -a "$file" "$OFFSITE_TARGET/"
  echo "$(date -Is) disalin ke $OFFSITE_TARGET"
fi
