import 'dart:math';

import 'package:undian_core/undian_core.dart';

/// Data contoh untuk mencoba aplikasi dan untuk tes: 400 peserta dan 10 hadiah. Nama dan NIK
/// dibuat acak, bukan data karyawan asli.
///
/// Pola grup mengikuti kebiasaan acara sebelumnya: doorprize per wilayah (Bogor/Jakarta), grand
/// prize hanya untuk pegawai tetap dan percobaan.
abstract final class SampleData {
  static const doorprizeBogor = 'Doorprize Bogor';
  static const doorprizeJakarta = 'Doorprize Jakarta';
  static const grandprizeBogor = 'Grandprize Bogor';
  static const grandprizeJakarta = 'Grandprize Jakarta';

  /// 10 hadiah urut rundown: 6 doorprize lalu 4 grand prize.
  static List<Prize> prizes() => const [
    Prize(
      id: 1,
      name: 'Voucher Belanja Rp200.000',
      kind: PrizeKind.doorprize,
      quantity: 30,
      eligibleGroups: {doorprizeBogor},
    ),
    Prize(
      id: 2,
      name: 'Tumbler Stainless',
      kind: PrizeKind.doorprize,
      quantity: 20,
      eligibleGroups: {doorprizeJakarta},
    ),
    Prize(
      id: 3,
      name: 'Kipas Angin Berdiri',
      kind: PrizeKind.doorprize,
      quantity: 15,
      eligibleGroups: {doorprizeBogor},
    ),
    Prize(id: 4, name: 'Hand Mixer', kind: PrizeKind.doorprize, quantity: 10, eligibleGroups: {doorprizeJakarta}),
    Prize(
      id: 5,
      name: 'Rice Cooker Digital',
      kind: PrizeKind.doorprize,
      quantity: 10,
      eligibleGroups: {doorprizeBogor, doorprizeJakarta},
    ),
    Prize(
      id: 6,
      name: 'Blender 2 Liter',
      kind: PrizeKind.doorprize,
      quantity: 8,
      eligibleGroups: {doorprizeBogor, doorprizeJakarta},
    ),
    Prize(
      id: 7,
      name: 'Smartphone 128 GB',
      kind: PrizeKind.grandprize,
      quantity: 3,
      eligibleGroups: {grandprizeBogor, grandprizeJakarta},
    ),
    Prize(
      id: 8,
      name: 'Smart TV 50 inci',
      kind: PrizeKind.grandprize,
      quantity: 2,
      eligibleGroups: {grandprizeJakarta},
    ),
    Prize(
      id: 9,
      name: 'Logam Mulia 10 gram',
      kind: PrizeKind.grandprize,
      quantity: 2,
      eligibleGroups: {grandprizeBogor, grandprizeJakarta},
    ),
    Prize(
      id: 10,
      name: 'Sepeda Motor Matic',
      kind: PrizeKind.grandprize,
      quantity: 1,
      eligibleGroups: {grandprizeBogor},
    ),
  ];

  /// 400 peserta dengan NIK unik. Hasilnya selalu sama (bibit acak tetap).
  static List<Participant> participants() {
    final rnd = Random(2026);
    final niks = <String>{};
    final result = <Participant>[];
    var id = 0;
    for (final (area, count) in _areas) {
      final bogor = area.startsWith('Bogor') || area == 'Sukabumi';
      for (var i = 0; i < count; i++) {
        final roll = rnd.nextDouble();
        final status = roll < 0.74
            ? 'Pegawai Tetap'
            : roll < 0.78
            ? 'Percobaan'
            : 'Kontrak';
        String nik;
        do {
          nik =
              '${_two(3 + rnd.nextInt(23))}${_two(1 + rnd.nextInt(12))}'
              '${(1 + rnd.nextInt(2999)).toString().padLeft(4, '0')}';
        } while (!niks.add(nik));
        final first = _firstNames[rnd.nextInt(_firstNames.length)];
        final name = rnd.nextDouble() < 0.1 ? first : '$first ${_lastNames[rnd.nextInt(_lastNames.length)]}';
        final pointsRoll = rnd.nextDouble();
        result.add(
          Participant(
            id: ++id,
            nik: nik,
            name: name,
            area: area,
            department: _departments[rnd.nextInt(_departments.length)],
            employmentStatus: status,
            groups: {
              bogor ? doorprizeBogor : doorprizeJakarta,
              if (status != 'Kontrak') bogor ? grandprizeBogor : grandprizeJakarta,
            },
            points: pointsRoll < 0.85
                ? 1
                : pointsRoll < 0.95
                ? 2
                : 3,
          ),
        );
      }
    }
    return result;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// Jumlah peserta per area; totalnya 400.
  static const _areas = [
    ('Bogor Plant', 241),
    ('Head Office', 101),
    ('Kebayoran Lama', 21),
    ('Bogor Non Plant', 9),
    ('Bekasi', 6),
    ('Tangerang', 6),
    ('Jakarta Selatan', 5),
    ('Jakarta Utara', 5),
    ('Karawang', 2),
    ('Sukabumi', 2),
    ('Serang', 2),
  ];

  static const _departments = [
    'Produksi',
    'Marketing',
    'Quality Control',
    'R&D',
    'Supply Chain',
    'Engineering',
    'General Affair',
    'Finance',
    'HRD',
    'ICT',
  ];

  static const _firstNames = [
    'Agus', 'Budi', 'Dewi', 'Siti', 'Rina', 'Andi', 'Eko', 'Fajar', 'Gita', 'Hendra', //
    'Indah', 'Joko', 'Kartika', 'Lestari', 'Maya', 'Nur', 'Putri', 'Rizki', 'Sari', 'Teguh',
    'Utami', 'Wahyu', 'Yogi', 'Yuni', 'Dimas', 'Ayu', 'Bayu', 'Citra', 'Dian', 'Fitri',
    'Galih', 'Hana', 'Ilham', 'Laras', 'Nanda', 'Oki', 'Pratiwi', 'Reza', 'Sinta', 'Tri',
  ];

  static const _lastNames = [
    'Pratama', 'Saputra', 'Wijaya', 'Hidayat', 'Nugroho', 'Kurniawan', 'Santoso', 'Setiawan', //
    'Rahmawati', 'Susanto', 'Purnomo', 'Wibowo', 'Hakim', 'Ramadhan', 'Maulana', 'Permana',
    'Anggraini', 'Firmansyah', 'Handayani', 'Siregar', 'Nasution', 'Gunawan', 'Halim', 'Sukmawati',
  ];
}
