# undian_flutter

Aplikasi Flutter (web + Windows) untuk admin, operator, dan layar panggung.

```
lib/
  main.dart              → buat client Serverpod, pulihkan sesi login, jalankan app
  app/                   → MaterialApp, router (redirect ke /masuk bila belum login), font
  core/
    data/                → UndianRepository: satu pintu data untuk semua halaman (server atau offline)
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
      gateway/           → sumber data panggung: demo, atau acara (server/offline)
    offline/             → mode offline (desktop)
      store/             → data offline di file laptop, aturan sama dengan server
      package/           → paket acara .undian (ekspor/impor antar laptop)
      backup/            → salinan otomatis acara dari server
      ui/                → dialog impor, tombol ekspor, penanda offline
```

## Mode offline (aplikasi Windows)

Untuk saat server bermasalah. Tombol **Mode offline (tanpa server)** ada di halaman masuk; tidak
perlu login. Data disimpan di `%APPDATA%\Undian\Undian\offline\data.json` (versi sebelumnya di
`data.json.bak`), dan aturan undian, stok, import, hadiah, serta status pemenang sama persis dengan
server karena memakai `undian_core`.

- **Salinan otomatis.** Saat online, setiap kali acara dibuka atau berubah (import, hadiah, undian,
  status), seluruh data acara disimpan di `%APPDATA%\Undian\Undian\Salinan otomatis\`. Status
  "Salinan offline 10.12" tampil di app bar halaman acara.
- **Paket acara (`.undian`).** Tombol ekspor di halaman acara (online maupun offline) menyimpan satu
  file berisi identitas organisasi, acara, peserta, hadiah, dan pemenang. File ini berisi data
  pribadi peserta, jadi perlakukan sebagai dokumen rahasia.
- **Pindah laptop.** Laptop B cukup memasang `Undian-Setup.exe`, pilih Mode offline → **Impor paket
  acara**, lalu undian bisa dilanjutkan. Paket yang diimpor ulang bisa mengganti salinan lamanya.
  Lanjutkan undian hanya di satu laptop pada satu waktu.
- Hasil undian offline belum bisa dikirim balik ke server (tahap berikutnya). Versi web selalu
  online.

## Menjalankan

```bash
flutter run -d chrome  --dart-define=SERVER_URL=http://localhost:8080/
flutter run -d windows --dart-define=SERVER_URL=http://localhost:8080/
```

Tanpa `SERVER_URL`, aplikasi memakai `http://localhost:8080/`. Mode demo (`/demo`) tidak butuh server.

## Template Excel peserta

`assets/templates/template_peserta.xlsx` berisi sheet Peserta (kosong, kolom NIK berformat Teks),
Contoh, dan Petunjuk. Isinya dibuat dari `lib/features/participants/import/participant_template.dart`;
setelah mengubah file itu, jalankan `dart run tool/generate_template.dart`.

## Installer Windows (Setup.exe)

Untuk dibagikan ke laptop lain. Butuh Flutter, Visual Studio 2022 (workload *Desktop development
with C++*), dan [Inno Setup 6](https://jrsoftware.org/isdl.php) di laptop yang membangun.

```powershell
powershell -ExecutionPolicy Bypass -File tool\build_windows_installer.ps1 -ServerUrl https://api.undian.contoh.co.id/
```

Hasilnya `build\installer\Undian-Setup-<versi>.exe` (sekitar 12 MB). Versi diambil dari `version:`
di `pubspec.yaml`; naikkan sebelum membagikan versi baru, maka installer akan memperbarui aplikasi
yang sudah terpasang.

- **Alamat server tertanam saat build.** `-ServerUrl` harus alamat API produksi (`API_DOMAIN` di
  `deploy/.env`) dan wajib `https://` kecuali `localhost`. Ganti server = build ulang installer.
- Dipasang tanpa hak admin ke `%LOCALAPPDATA%\Programs\Undian`, dengan pintasan Start Menu dan
  (opsional) desktop. Uninstall lewat *Settings → Apps*.
- Runtime Visual C++ ikut dibundel, jadi laptop tujuan tidak perlu memasang apa pun lagi.
- Installer belum ditandatangani (*code signing*), sehingga Windows SmartScreen bisa menampilkan
  "Windows protected your PC": klik **More info → Run anyway**.
- Pemasangan senyap untuk banyak laptop: `Undian-Setup-<versi>.exe /VERYSILENT /SUPPRESSMSGBOXES`.

Ikon aplikasi (`windows/runner/resources/app_icon.ico`, `web/favicon.png`, `web/icons/`) dan gambar
wizard installer digambar oleh `tool/generate_icons.dart`; setelah mengubah desainnya jalankan
`dart run tool/generate_icons.dart`.

## Data demo di server lokal

`dart run tool/seed_demo.dart <file-log-server>` membuat akun, organisasi, dan acara demo
(430 peserta fiktif, 6 hadiah) di server pengembangan. Jangan dipakai ke server produksi.

## Tes

```bash
flutter test                                   # unit & widget
flutter test integration_test/e2e_test.dart -d windows \
  --dart-define=SERVER_URL=http://localhost:8080/ \
  --dart-define=SERVER_LOG=<file log server>   # ujung-ke-ujung, butuh server lokal berjalan
```

Aturan kode dan struktur keseluruhan ada di README root.
