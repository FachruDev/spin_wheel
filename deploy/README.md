# Deploy ke VPS

Satu `docker compose` menjalankan semuanya di VPS Linux:

| Service | Isi | Dibuka ke internet |
|---|---|---|
| `postgres` | Database PostgreSQL 16 (volume `db_data`) | Tidak |
| `server` | Server Serverpod (`undian_server`), menerapkan migrasi otomatis saat start | Tidak (lewat nginx) |
| `web` | nginx: aplikasi Flutter web + proxy HTTPS ke API | Port 80 & 443 |
| `certbot` | Memperpanjang sertifikat Let's Encrypt tiap 12 jam | Tidak |

Domain: `APP_DOMAIN` untuk aplikasi, `API_DOMAIN` untuk API. Keduanya harus sudah
mengarah (A record) ke IP VPS.

## Pertama kali

```bash
# 1. Pasang Docker Engine + plugin compose di VPS, lalu ambil kode
git clone https://github.com/FachruDev/spin_wheel.git /opt/undian
cd /opt/undian/deploy

# 2. Isi konfigurasi dan rahasia (buat nilai acak dengan: openssl rand -base64 48)
cp .env.example .env
nano .env
chmod 600 .env

# 3. Sertifikat HTTPS pertama
bash scripts/init-cert.sh

# 4. Build dan jalankan
docker compose up -d --build
docker compose logs -f server
```

Build pertama cukup lama (mengunduh image Dart dan Flutter, sekitar 3 GB). VPS minimal
2 vCPU / 4 GB RAM supaya build Flutter web tidak kehabisan memori.

## Memperbarui aplikasi

```bash
cd /opt/undian && git pull
cd deploy && docker compose up -d --build
```

Migrasi database diterapkan otomatis saat container `server` start.

## Backup

```bash
bash scripts/backup.sh                  # backup sekarang ke deploy/backups/
crontab -e                              # tambahkan backup harian:
# 15 2 * * * bash /opt/undian/deploy/scripts/backup.sh >> /var/log/undian-backup.log 2>&1
```

Backup lebih dari 14 hari dihapus otomatis (`KEEP_DAYS`). Isi `OFFSITE_TARGET` di `.env`
supaya tiap backup juga disalin ke server lain dengan rsync. Uji pemulihan sesekali:

```bash
bash scripts/restore.sh backups/undian-YYYYmmdd-HHMMSS.sql.gz
```

## Catatan keamanan

- `.env`, `backups/`, dan `certbot/` tidak ikut git (lihat `.gitignore` di root).
- Database dan port Serverpod tidak dibuka ke internet; hanya nginx (80/443).
- Repo ini publik: jangan pernah menaruh password, data karyawan, atau file backup di dalamnya.
