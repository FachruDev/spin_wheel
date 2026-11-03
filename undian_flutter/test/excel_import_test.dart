import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undian_flutter/features/participants/import/column_mapping.dart';
import 'package:undian_flutter/features/participants/import/excel_table_reader.dart';
import 'package:undian_flutter/features/participants/import/participant_template.dart';

/// Membuat file .xlsx di memori dengan baris-baris [rows] di sheet pertama.
List<int> workbook(List<List<Object?>> rows) {
  final book = Excel.createExcel();
  final sheet = book[book.getDefaultSheet()!];
  for (final row in rows) {
    sheet.appendRow([
      for (final v in row)
        switch (v) {
          null => null,
          int() => IntCellValue(v),
          _ => TextCellValue('$v'),
        },
    ]);
  }
  return book.encode()!;
}

void main() {
  test('file HRD: judul kolom di baris 1, dua kolom grup tanpa judul', () {
    final bytes = workbook([
      ['No', 'No. Karyawan', 'Nama Karyawan', 'Lokasi Kerja', 'Cost Center', 'Status Karyawan'],
      [1, '03090234', 'Andi', 'Head Office', 'ATS', 'Pegawai Tetap', 'Doorprize Jakarta', 'Grandprize Jakarta'],
      [2, '04090246', 'Budi', 'Bogor Plant', 'QC', 'Kontrak 1', 'Doorprize Bogor', null],
    ]);
    final table = readWorkbook(bytes).single.table();
    final mapping = guessMapping(table);
    expect(mapping, {
      1: ImportField.nik,
      2: ImportField.name,
      3: ImportField.area,
      4: ImportField.department,
      5: ImportField.employmentStatus,
      6: ImportField.group,
      7: ImportField.group,
    });
    final rows = mapRows(table, mapping);
    expect(rows.map((r) => r.input!.nik), ['03090234', '04090246'], reason: 'nol di depan NIK teks tetap ada');
    expect(rows.first.input!.groups, ['Doorprize Jakarta', 'Grandprize Jakarta']);
    expect(rows.last.input!.groups, ['Doorprize Bogor']);
    expect(rows.first.input!.points, 1);
  });

  test('template aplikasi lama dan baris judul dokumen di atas tabel', () {
    final bytes = workbook([
      ['DAFTAR ANGGOTA KOPERASI 2025'],
      ['RAT 2025'],
      ['ID', 'no_undian', 'nama_peserta', 'cabang_peserta', 'hp_peserta', 'sudah_menang', 'kriteria1', 'poin'],
      [1, 15012897, 'Citra', 'Bogor', '0812', 'belum', 'GPL_YASA_AXEL; Daerah', 3],
    ]);
    final sheet = readWorkbook(bytes).single;
    expect(sheet.detectedHeaderRow, 2);
    final table = sheet.table();
    final mapping = guessMapping(table);
    expect(mapping.values, containsAll([ImportField.nik, ImportField.name, ImportField.area, ImportField.phone]));
    final input = mapRows(table, mapping).single.input!;
    expect(input.nik, '15012897', reason: 'NIK yang tersimpan sebagai angka tidak berakhiran .0');
    expect(input.groups, ['Daerah', 'GPL_YASA_AXEL']);
    expect(input.points, 3);
    expect(input.phone, '0812');
  });

  test('baris bermasalah dilewati dengan alasan, NIK ganda tidak menimpa', () {
    final bytes = workbook([
      ['NIK', 'Nama', 'Poin'],
      ['001', 'Andi', ''],
      ['', 'Tanpa NIK', ''],
      ['002', '', ''],
      ['003', 'Citra', 'dua'],
      ['001', 'Andi Lagi', ''],
    ]);
    final table = readWorkbook(bytes).single.table();
    final rows = mapRows(table, guessMapping(table));
    expect(rows.where((r) => r.isValid).map((r) => r.input!.name), ['Andi']);
    expect(rows.where((r) => !r.isValid).map((r) => r.error), [
      'NIK kosong',
      'Nama kosong',
      'Poin "dua" harus angka minimal 1',
      'NIK 001 ganda (sama dengan baris 2)',
    ]);
  });

  test('NIK dan Nama wajib dipetakan', () {
    expect(mappingProblem({0: ImportField.nik}), contains('Nama'));
    expect(mappingProblem({0: ImportField.nik, 1: ImportField.name}), isNull);
  });

  test('template: judul kolom dikenali otomatis, contoh terbaca, sheet Peserta masih kosong', () {
    final sheets = readWorkbook(buildParticipantTemplate(preformattedRows: 20));
    expect(sheets.map((s) => s.name), containsAllInOrder(['Peserta', 'Contoh', 'Petunjuk']));

    final empty = sheets.firstWhere((s) => s.name == 'Peserta').table();
    expect(guessMapping(empty), {
      0: ImportField.nik,
      1: ImportField.name,
      2: ImportField.area,
      3: ImportField.department,
      4: ImportField.employmentStatus,
      5: ImportField.phone,
      6: ImportField.points,
      7: ImportField.group,
      8: ImportField.group,
      9: ImportField.group,
    });
    expect(mapRows(empty, guessMapping(empty)), isEmpty);

    final example = sheets.firstWhere((s) => s.name == 'Contoh').table();
    final rows = mapRows(example, guessMapping(example));
    expect(rows.every((r) => r.isValid), isTrue);
    expect(rows.first.input!.nik, '03090234');
    expect(rows[1].input!.points, 2);
    expect(rows.last.input!.groups, ['Doorprize Bogor', 'Grandprize Bogor']);
  });

  test('huruf kolom Excel', () {
    expect([0, 6, 25, 26, 27].map(columnLetter), ['A', 'G', 'Z', 'AA', 'AB']);
  });
}
