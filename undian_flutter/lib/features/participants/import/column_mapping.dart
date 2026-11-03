import 'package:undian_client/undian_client.dart';

import 'excel_table_reader.dart';

/// Kolom data peserta yang bisa diisi dari Excel.
enum ImportField {
  nik('NIK / No. undian', required: true),
  name('Nama', required: true),
  area('Area / lokasi'),
  department('Departemen'),
  employmentStatus('Status karyawan'),
  phone('No. HP'),
  points('Poin'),

  /// Boleh lebih dari satu kolom; isinya juga boleh beberapa grup dipisah koma/titik koma.
  group('Grup');

  const ImportField(this.label, {this.required = false});

  final String label;
  final bool required;
}

/// Pemetaan kolom → isian. Kolom yang tidak ada di peta diabaikan.
typedef ColumnMapping = Map<int, ImportField>;

/// Menebak pemetaan dari judul kolom. Cocok untuk template lama (no_undian, nama_peserta,
/// cabang_peserta, kriteria1, poin) maupun file HR (No. Karyawan, Lokasi Kerja, Cost Center).
ColumnMapping guessMapping(SheetTable table) {
  final mapping = <int, ImportField>{};
  for (var c = 0; c < table.columnCount; c++) {
    final field = _guessField(table.headers[c], table.sample(c));
    if (field == null) continue;
    final takenOnce = field != ImportField.group && mapping.containsValue(field);
    if (!takenOnce) mapping[c] = field;
  }
  return mapping;
}

ImportField? _guessField(String header, String sample) {
  final h = header.toLowerCase().replaceAll(RegExp(r'[_.\-/]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  final words = h.split(' ').toSet();
  if (h.isEmpty) {
    // Kolom tanpa judul berisi teks (mis. "Doorprize Jakarta") biasanya grup.
    return sample.isNotEmpty && int.tryParse(sample) == null ? ImportField.group : null;
  }
  if (words.contains('nik') ||
      h.contains('no karyawan') ||
      h.contains('nomor karyawan') ||
      h.contains('no undian') ||
      h.contains('nomor undian') ||
      h.contains('nomor induk')) {
    return ImportField.nik;
  }
  if (h.contains('nama')) return ImportField.name;
  if (h.contains('lokasi') || h.contains('area') || h.contains('cabang') || h.contains('wilayah')) {
    return ImportField.area;
  }
  if (h.contains('departemen') ||
      h.contains('department') ||
      h.contains('divisi') ||
      h.contains('bagian') ||
      h.contains('cost center')) {
    return ImportField.department;
  }
  if (h.contains('status')) return ImportField.employmentStatus;
  if (words.contains('hp') || h.contains('telepon') || h.contains('phone') || h.contains('telp')) {
    return ImportField.phone;
  }
  if (h.contains('poin') || h.contains('point')) return ImportField.points;
  if (h.contains('grup') || h.contains('group') || h.contains('kriteria') || h.contains('kategori')) {
    return ImportField.group;
  }
  return null;
}

/// Pesan bila pemetaan belum bisa dipakai, mis. kolom NIK belum dipilih.
String? mappingProblem(ColumnMapping mapping) {
  final missing = [
    for (final f in ImportField.values)
      if (f.required && !mapping.containsValue(f)) f.label,
  ];
  return missing.isEmpty ? null : 'Pilih kolom untuk: ${missing.join(', ')}.';
}

/// Satu baris Excel setelah dipetakan: data siap kirim, atau alasan ditolak.
class MappedRow {
  const MappedRow({required this.excelRow, this.input, this.error});

  final int excelRow;
  final ParticipantInput? input;
  final String? error;

  bool get isValid => input != null;
}

/// Mengubah baris tabel menjadi data peserta. Baris kosong (semua kolom terpetakan kosong)
/// dilewati; NIK ganda dalam file ditandai salah supaya tidak diam-diam tertimpa.
List<MappedRow> mapRows(SheetTable table, ColumnMapping mapping) {
  String value(List<String> cells, ImportField field) {
    final column = mapping.entries.where((e) => e.value == field).firstOrNull?.key;
    return column == null ? '' : cells[column].trim();
  }

  final seen = <String, int>{};
  final result = <MappedRow>[];
  for (final (:excelRow, :cells) in table.rows) {
    if (mapping.keys.every((c) => cells[c].trim().isEmpty)) continue;
    final nik = value(cells, ImportField.nik);
    final name = value(cells, ImportField.name);
    final pointsText = value(cells, ImportField.points);
    final points = pointsText.isEmpty ? 1 : int.tryParse(pointsText);
    final String? error;
    if (nik.isEmpty) {
      error = 'NIK kosong';
    } else if (name.isEmpty) {
      error = 'Nama kosong';
    } else if (points == null || points < 1) {
      error = 'Poin "$pointsText" harus angka minimal 1';
    } else if (seen[nik] case final first?) {
      error = 'NIK $nik ganda (sama dengan baris $first)';
    } else {
      error = null;
    }
    if (error != null) {
      result.add(MappedRow(excelRow: excelRow, error: error));
      continue;
    }
    seen[nik] = excelRow;
    final groups = <String>{
      for (final MapEntry(key: column, value: field) in mapping.entries)
        if (field == ImportField.group)
          for (final g in cells[column].split(RegExp(r'[,;|]')))
            if (g.trim().isNotEmpty) g.trim(),
    };
    final phone = value(cells, ImportField.phone);
    result.add(
      MappedRow(
        excelRow: excelRow,
        input: ParticipantInput(
          nik: nik,
          name: name,
          area: value(cells, ImportField.area),
          department: value(cells, ImportField.department),
          employmentStatus: value(cells, ImportField.employmentStatus),
          phone: phone.isEmpty ? null : phone,
          points: points!,
          groups: groups.toList()..sort(),
        ),
      ),
    );
  }
  return result;
}
