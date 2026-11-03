# Undian

Aplikasi undian doorprize & grand prize untuk acara perusahaan. Bisa dipakai banyak
organisasi (SaaS gratis): tiap organisasi mengatur nama, logo, warna, acara, peserta, dan
hadiahnya sendiri. Berjalan di web dan desktop Windows.

## Struktur

```
spin_wheel/
  undian_server/   → Serverpod: endpoint, model, migrasi database
  undian_client/   → dibuat otomatis oleh Serverpod (jangan diedit manual)
  undian_flutter/  → aplikasi Flutter (web + Windows)
  undian_core/     → logika undian murni Dart (kelayakan, stok, undian berbobot poin),
                     dipakai server dan aplikasi
  deploy/          → docker-compose produksi, konfigurasi nginx, skrip backup
```

Root adalah *pub workspace*: satu `flutter pub get` di root mengambil dependency semua paket,
dengan satu `pubspec.lock` bersama.

## Menjalankan di laptop

```bash
flutter pub get                                   # sekali, di root

cd undian_server
docker compose up -d postgres postgres_test       # database lokal (butuh Docker Desktop)
dart bin/main.dart --apply-migrations             # API di http://localhost:8080

cd ../undian_flutter
flutter run -d chrome                             # atau: -d windows
```

## Tes

```bash
cd undian_core && dart test
cd undian_server && dart test        # butuh postgres_test dari docker compose
cd undian_flutter && flutter test
```

## Aturan kode

- Satu file kode maksimal **700 baris** (idealnya di bawah 500). Kalau lebih, pecah per
  tanggung jawab: widget, controller, atau helper ke file sendiri. File hasil generate
  (`**/generated/**`, `undian_client/lib/src/protocol/**`) dikecualikan.
- Satu fitur satu folder di `undian_flutter/lib/features/<fitur>/`.
- Logika undian hanya di `undian_core`; server dan aplikasi tidak menulis ulang aturannya.
- Setelah mengubah model atau endpoint server: `serverpod generate`, lalu
  `serverpod create-migration` bila skema database berubah.
- Lebar baris 120 karakter (`dart format`).

## Deploy

Lihat [deploy/README.md](deploy/README.md).
