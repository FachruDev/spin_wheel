# undian_server

Server Serverpod untuk aplikasi undian. Satu server melayani banyak organisasi (tenant);
setiap acara, peserta, hadiah, pemenang, dan log audit berada di bawah satu organisasi,
dan setiap endpoint memeriksa keanggotaan pengguna yang login.

## Menjalankan di komputer sendiri

Butuh Docker Desktop yang sedang menyala.

    docker compose up --detach postgres postgres_test
    dart bin/main.dart --apply-migrations

API berjalan di `http://localhost:8080`, halaman web di `http://localhost:8082`.
Kode verifikasi daftar akun email tampil di log server (belum ada layanan email).

## Setelah mengubah model (`lib/src/models/*.spy.yaml`) atau endpoint

    serverpod generate
    serverpod create-migration
    dart bin/main.dart --apply-migrations --role maintenance

`serverpod` ada di `%LOCALAPPDATA%\Pub\Cache\bin`. Gunakan versi CLI yang sama dengan
paket (`3.4.13`).

## Tes

    dart test

Tes integrasi memakai database `postgres_test` (port 9090) dan setiap tes di-rollback.

## Isi utama

- `lib/src/models/` — skema: organization, membership, draw_event, participant, prize, winner, audit_log.
- `lib/src/access.dart` — pengecekan login, keanggotaan, dan peran (admin / drawOperator / viewer).
- `lib/src/endpoints/` — organization, event, participant (import), prize, draw.
- Logika undian berbobot ada di `../packages/undian_core`, dipakai juga oleh aplikasi.
