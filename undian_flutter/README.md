# undian_flutter

Aplikasi Flutter (web + Windows) untuk admin, operator, dan layar panggung.

```
lib/
  main.dart              → buat client Serverpod, pulihkan sesi login, jalankan app
  app/                   → MaterialApp, router (redirect ke /masuk bila belum login), font
  core/
    server/              → client Serverpod (SERVER_URL), konversi model server → undian_core
    ui/                  → tampilan async/error/kosong, dialog, format tanggal
  features/
    auth/                → masuk, daftar akun, lupa password (email)
    organizations/       → organisasi saya, identitas (nama, logo, warna)
    events/              → daftar acara, halaman acara (tab peserta/hadiah/pemenang)
    participants/        → daftar peserta + import Excel (baca .xlsx, cocokkan kolom, pratinjau)
    prizes/              → hadiah, stok, grup yang berhak
    winners/             → pemenang per putaran, ubah status (diserahkan/ditransfer/hangus)
    branding/            → model & dialog identitas, logo
    stage/               → layar panggung, panel operator, animasi
      gateway/           → sumber data panggung: demo (lokal) atau server
```

## Menjalankan

```bash
flutter run -d chrome  --dart-define=SERVER_URL=http://localhost:8080/
flutter run -d windows --dart-define=SERVER_URL=http://localhost:8080/
```

Tanpa `SERVER_URL`, aplikasi memakai `http://localhost:8080/`. Mode demo (`/demo`) tidak butuh server.

## Tes

```bash
flutter test                                   # unit & widget
flutter test integration_test/e2e_test.dart -d windows \
  --dart-define=SERVER_URL=http://localhost:8080/ \
  --dart-define=SERVER_LOG=<file log server>   # ujung-ke-ujung, butuh server lokal berjalan
```

Aturan kode dan struktur keseluruhan ada di README root.
