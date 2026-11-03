# undian_flutter

Aplikasi Flutter (web + Windows) untuk operator, admin, dan layar panggung.

```
lib/
  main.dart
  app/                 → MaterialApp, router, font
  features/
    branding/          → identitas organisasi (nama, logo, warna)
    stage/             → layar panggung, panel operator, controller undian
      widgets/         → animasi: kartu kocok, drum 3D, buka NIK, confetti, latar
```

Jalankan dari folder ini: `flutter run -d chrome` atau `flutter run -d windows`.
Aturan kode dan struktur keseluruhan ada di README root.
