import 'dart:math';

import 'package:excel/excel.dart' as xl;

/// Isi mentah satu sheet: semua baris sebagai teks.
class SheetData {
  const SheetData(this.name, this.rows);

  final String name;
  final List<List<String>> rows;

  /// Baris pertama yang terisi cukup banyak (≥ separuh lebar tabel) dianggap judul kolom.
  /// Baris judul dokumen seperti "DAFTAR ANGGOTA 2025" yang hanya 1 sel akan dilewati.
  int get detectedHeaderRow {
    final width = rows.fold(0, (w, r) => max(w, _filled(r)));
    final threshold = max(2, (width / 2).ceil());
    for (var i = 0; i < min(rows.length, 20); i++) {
      if (_filled(rows[i]) >= threshold) return i;
    }
    return 0;
  }

  /// Tabel dengan baris judul [headerRow] (bawaan: hasil deteksi).
  SheetTable table({int? headerRow}) {
    final header = headerRow ?? detectedHeaderRow;
    final width = rows.fold(0, (w, r) => max(w, _lastFilled(r) + 1));
    List<String> pad(List<String> r) => [for (var c = 0; c < width; c++) c < r.length ? r[c] : ''];
    return SheetTable(
      sheetName: name,
      headerRowIndex: header,
      headers: pad(header < rows.length ? rows[header] : const []),
      rows: [
        for (var i = header + 1; i < rows.length; i++)
          if (rows[i].any((c) => c.isNotEmpty)) (excelRow: i + 1, cells: pad(rows[i])),
      ],
    );
  }

  static int _filled(List<String> r) => r.where((c) => c.isNotEmpty).length;

  static int _lastFilled(List<String> r) => r.lastIndexWhere((c) => c.isNotEmpty);
}

/// Tabel siap dipetakan: judul kolom dan baris data (nomor baris sesuai Excel, mulai 1).
class SheetTable {
  const SheetTable({required this.sheetName, required this.headerRowIndex, required this.headers, required this.rows});

  final String sheetName;
  final int headerRowIndex;
  final List<String> headers;
  final List<({int excelRow, List<String> cells})> rows;

  int get columnCount => headers.length;

  /// Nama kolom untuk ditampilkan; kolom tanpa judul memakai huruf Excel, mis. "Kolom G".
  String columnLabel(int index) => headers[index].isEmpty ? 'Kolom ${columnLetter(index)}' : headers[index];

  /// Contoh isi kolom (nilai terisi pertama), untuk membantu pemetaan.
  String sample(int index) => rows.map((r) => r.cells[index]).firstWhere((v) => v.isNotEmpty, orElse: () => '');
}

/// Membaca semua sheet yang berisi data dari file .xlsx.
List<SheetData> readWorkbook(List<int> bytes) {
  final book = xl.Excel.decodeBytes(bytes);
  return [
    for (final MapEntry(key: name, value: sheet) in book.tables.entries)
      if (_sheetRows(sheet) case final rows when rows.isNotEmpty) SheetData(name, rows),
  ];
}

List<List<String>> _sheetRows(xl.Sheet sheet) {
  final rows = [
    for (final row in sheet.rows) [for (final cell in row) cellText(cell?.value)],
  ];
  while (rows.isNotEmpty && rows.last.every((c) => c.isEmpty)) {
    rows.removeLast();
  }
  return rows;
}

/// Isi sel sebagai teks. Angka bulat ditulis tanpa ".0" (NIK yang tersimpan sebagai angka).
String cellText(xl.CellValue? value) => switch (value) {
  null => '',
  xl.IntCellValue(:final value) => '$value',
  xl.DoubleCellValue(:final value) => value == value.truncateToDouble() ? '${value.toInt()}' : '$value',
  _ => value.toString().trim(),
};

/// Huruf kolom Excel: 0 → A, 25 → Z, 26 → AA.
String columnLetter(int index) {
  var n = index + 1;
  var label = '';
  while (n > 0) {
    final r = (n - 1) % 26;
    label = String.fromCharCode(65 + r) + label;
    n = (n - 1) ~/ 26;
  }
  return label;
}
