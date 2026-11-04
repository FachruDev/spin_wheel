# Deploy ke VPS

Satu `docker compose` menjalankan semuanya di VPS Linux:

| Service | Isi | Dibuka ke internet |
|---|---|---|
| `postgres` | Database PostgreSQL 16 (volume `db_data`) | Tidak |
| `server` | Server Serverpod (`undian_server`), menerapkan migrasi otomatis saat start | Tidak (lewat nginx) |
| `web` | nginx: aplikasi Flutter web + proxy HTTPS ke API | Port 80 & 443 |
| `certbot` | Memperpanjang sertifikat Let's Encrypt tiap 12 jam | Tidak |

## Yang perlu disiapkan

- **VPS** Ubuntu 22.04/24.04, minimal 2 vCPU, 4 GB RAM, 20 GB disk. RAM 4 GB dibutuhkan saat
  build aplikasi web; di VPS 2 GB tambahkan swap (lihat bagian *Masalah umum*).
- **Dua domain/subdomain** yang sudah diarahkan (A record) ke IP VPS, mis.
  `undian.perusahaan.co.id` (aplikasi) dan `api.undian.perusahaan.co.id` (API).
- **Akun email SMTP** untuk mengirim kode verifikasi pendaftaran, mis. email kantor atau layanan
  seperti Brevo/Mailgun/Amazon SES. Tanpa ini, orang tidak bisa membuat akun.

## Pertama kali

```bash
# 1. Pasang Docker dan buka firewall untuk SSH, HTTP, HTTPS
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER" && newgrp docker
sudo ufw allow OpenSSH && sudo ufw allow 80/tcp && sudo ufw allow 443/tcp && sudo ufw enable

# 2. Ambil kode
sudo git clone https://github.com/FachruDev/spin_wheel.git /opt/undian
sudo chown -R "$USER" /opt/undian
cd /opt/undian/deploy

# 3. Buat .env: rahasia diisi acak otomatis, sisanya isi manual (domain, email, SMTP)
bash scripts/init-env.sh
nano .env

# 4. Sertifikat HTTPS pertama (domain harus sudah mengarah ke VPS)
bash scripts/init-cert.sh

# 5. Build, jalankan, dan cek
bash scripts/deploy.sh --no-pull
```

Build pertama makan waktu 10–20 menit (mengunduh image Dart dan Flutter, sekitar 3 GB).
Di akhir, `deploy.sh` menjalankan `check.sh` yang harus menampilkan **OK: aplikasi siap dipakai**.

Setelah itu buka `https://<APP_DOMAIN>`, pilih **Belum punya akun? Daftar**, masukkan kode dari
email, lalu buat organisasi. Pembuat organisasi otomatis menjadi admin.

## Memperbarui aplikasi

```bash
cd /opt/undian/deploy
bash scripts/deploy.sh
```

Skrip ini: `git pull` → backup database → build → jalankan → cek. Migrasi database diterapkan
otomatis saat container `server` start.

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

## Skrip

| Skrip | Fungsi |
|---|---|
| `scripts/init-env.sh` | Membuat `.env`, mengisi rahasia acak, menampilkan isian yang masih kosong |
| `scripts/init-cert.sh` | Mengambil sertifikat HTTPS pertama untuk kedua domain |
| `scripts/deploy.sh` | Pasang/perbarui: pull, backup, build, jalankan, cek |
| `scripts/check.sh` | Cek container, API (harus 401), dan aplikasi web (harus 200) |
| `scripts/backup.sh` / `restore.sh` | Backup harian dan pemulihan database |

## Masalah umum

- **Build web berhenti/killed**: RAM kurang. Tambahkan swap 4 GB lalu ulangi `deploy.sh`:
  `sudo fallocate -l 4G /swapfile && sudo chmod 600 /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile`
- **`init-cert.sh` gagal**: pastikan kedua domain sudah mengarah ke IP VPS (`dig +short <domain>`)
  dan port 80 terbuka.
- **Daftar akun gagal**: cek pengaturan SMTP di `.env`, lalu `docker compose logs --tail 50 server`.
- **Lihat log**: `docker compose logs -f server` atau `docker compose logs -f web`.

## Catatan keamanan

- `.env`, `backups/`, dan `certbot/` tidak ikut git (lihat `.gitignore` di root).
- Database dan port Serverpod tidak dibuka ke internet; hanya nginx (80/443).
- Jangan pernah mengganti nilai rahasia di `.env` setelah aplikasi dipakai (sesi login dan kode
  verifikasi lama menjadi tidak berlaku), kecuali memang ingin memaksa semua orang login ulang.
- Repo ini publik: jangan pernah menaruh password, data karyawan, atau file backup di dalamnya.
