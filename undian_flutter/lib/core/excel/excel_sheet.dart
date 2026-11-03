import 'package:excel/excel.dart' as xl;

/// Gaya judul kolom yang dipakai semua file Excel buatan aplikasi.
final excelHeaderStyle = xl.CellStyle(
  bold: true,
  fontColorHex: xl.ExcelColor.white,
  backgroundColorHex: xl.ExcelColor.fromHexString('#4F46E5'),
);

/// Format Teks (@) supaya angka seperti NIK 03090234 tidak kehilangan nol di depan.
final excelTextStyle = xl.CellStyle(numberFormat: xl.NumFormat.standard_49);

/// Menulis baris judul di baris pertama [sheet] beserta lebar kolomnya.
void writeExcelHeader(xl.Sheet sheet, List<String> headers, List<double> widths) {
  for (var c = 0; c < headers.length; c++) {
    if (c < widths.length) sheet.setColumnWidth(c, widths[c]);
    final cell = sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0));
    cell.value = xl.TextCellValue(headers[c]);
    cell.cellStyle = excelHeaderStyle;
  }
}

/// Menulis [rows] mulai baris kedua. Nilai `String` ditulis sebagai teks, `int` sebagai angka;
/// kolom di [textColumns] diberi format Teks.
void writeExcelRows(xl.Sheet sheet, List<List<Object?>> rows, {Set<int> textColumns = const {}}) {
  for (var r = 0; r < rows.length; r++) {
    for (var c = 0; c < rows[r].length; c++) {
      final value = rows[r][c];
      if (value == null || value == '') continue;
      final cell = sheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
      cell.value = value is int ? xl.IntCellValue(value) : xl.TextCellValue('$value');
      if (textColumns.contains(c)) cell.cellStyle = excelTextStyle;
    }
  }
}
