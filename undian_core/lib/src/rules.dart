import 'dart:math';

import 'models.dart';

/// Aturan data acara yang berlaku sama di server dan di mode offline aplikasi.
///
/// Fungsi `...Problem` mengembalikan pesan kesalahan untuk pengguna, atau null bila data sah.
abstract final class UndianRules {
  static const maxWinnersPerRound = 50;

  /// Warna awal organisasi baru (ARGB): indigo dan emas.
  static const defaultPrimaryColor = 0xFF4F46E5;
  static const defaultAccentColor = 0xFFF5C04E;
  static const maxLogoBytes = 300 * 1024;

  /// Jumlah peserta berhak (diacak) yang dikirim ke panggung untuk animasi.
  static const poolSampleSize = 1000;

  static const replaceAllWithWinnersMessage =
      'Acara ini sudah punya pemenang, jadi data peserta tidak bisa diganti total. '
      'Gunakan mode tambah/perbarui.';
  static const deleteDrawnPrizeMessage = 'Hadiah yang sudah diundi tidak bisa dihapus.';

  /// [what] mis. "organisasi", "acara", "hadiah".
  static String? nameProblem(String name, String what) => name.trim().isEmpty ? 'Nama $what wajib diisi.' : null;

  static String? logoProblem(int? lengthInBytes) =>
      lengthInBytes != null && lengthInBytes > maxLogoBytes ? 'Ukuran logo maksimal 300 KB.' : null;

  static String? drawCountProblem(int count) =>
      count < 1 || count > maxWinnersPerRound ? 'Jumlah pemenang per putaran harus 1–$maxWinnersPerRound.' : null;

  /// Nomor putaran berikutnya dalam satu acara.
  static int nextRoundNo(Iterable<int> existingRoundNos) => existingRoundNos.fold(0, max) + 1;

  /// Nama grup tanpa spasi tepi, tanpa duplikat dan yang kosong, urut abjad.
  static List<String> cleanGroups(Iterable<String> groups) => {
    for (final g in groups)
      if (g.trim().isNotEmpty) g.trim(),
  }.toList()..sort();

  /// [groups] sudah dibersihkan dengan [cleanGroups].
  static String? prizeProblem({
    required String name,
    required int quantity,
    required bool openToAll,
    required List<String> groups,
  }) {
    final nameIssue = nameProblem(name, 'hadiah');
    if (nameIssue != null) return nameIssue;
    if (quantity < 1) return 'Jumlah unit minimal 1.';
    if (!openToAll && groups.isEmpty) {
      return 'Pilih minimal satu grup peserta, atau buka hadiah untuk semua peserta.';
    }
    return null;
  }

  /// Jumlah unit hadiah tidak boleh kurang dari unit yang sudah terundi (tidak hangus).
  static String? prizeQuantityProblem({required int quantity, required int used}) =>
      quantity < used ? 'Sudah $used unit terundi; jumlah unit tidak boleh kurang dari itu.' : null;

  /// Hangus wajib beralasan dan bersifat final, karena unitnya kembali ke stok.
  static String? statusChangeProblem({required WinnerStatus current, required WinnerStatus next, String? note}) {
    if (next == WinnerStatus.hangus && (note == null || note.trim().isEmpty)) {
      return 'Alasan wajib diisi untuk menandai hangus.';
    }
    if (current == WinnerStatus.hangus) return 'Pemenang yang sudah hangus tidak bisa diubah statusnya.';
    return null;
  }

  /// Memeriksa baris import peserta. Baris sah dirapikan (spasi tepi, grup) dan dikelompokkan
  /// per NIK; baris yang ditolak dicatat dengan nomor barisnya.
  static ImportPlan planImport(List<ImportRow> rows) {
    final rejected = <String>[];
    final valid = <String, ImportRow>{};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final line = 'Baris ${i + 1}';
      final nik = row.nik.trim();
      if (nik.isEmpty) {
        rejected.add('$line: NIK kosong');
      } else if (row.name.trim().isEmpty) {
        rejected.add('$line ($nik): nama kosong');
      } else if (row.points < 1) {
        rejected.add('$line ($nik): poin harus minimal 1');
      } else if (valid.containsKey(nik)) {
        rejected.add('$line: NIK $nik muncul lebih dari sekali');
      } else {
        valid[nik] = row.cleaned();
      }
    }
    return ImportPlan(valid: valid, rejected: rejected);
  }
}

/// Satu baris peserta dari file Excel.
class ImportRow {
  const ImportRow({
    required this.nik,
    required this.name,
    this.area = '',
    this.department = '',
    this.employmentStatus = '',
    this.phone,
    this.points = 1,
    this.groups = const [],
  });

  final String nik;
  final String name;
  final String area;
  final String department;
  final String employmentStatus;
  final String? phone;
  final int points;
  final List<String> groups;

  ImportRow cleaned() => ImportRow(
    nik: nik.trim(),
    name: name.trim(),
    area: area.trim(),
    department: department.trim(),
    employmentStatus: employmentStatus.trim(),
    phone: phone?.trim(),
    points: points,
    groups: UndianRules.cleanGroups(groups),
  );
}

/// Hasil [UndianRules.planImport].
class ImportPlan {
  const ImportPlan({required this.valid, required this.rejected});

  /// Baris sah yang sudah dirapikan, per NIK, sesuai urutan di file.
  final Map<String, ImportRow> valid;
  final List<String> rejected;
}
