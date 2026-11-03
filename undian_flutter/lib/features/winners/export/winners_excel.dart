import 'package:excel/excel.dart' as xl;

import '../../../core/excel/excel_sheet.dart';
import '../../../core/ui/format.dart';
import 'winner_report.dart';

const _winnerHeaders = [
  'No',
  'Putaran',
  'Hadiah',
  'Jenis',
  'NIK',
  'Nama',
  'Area',
  'Departemen',
  'Status',
  'Waktu undian',
  'Catatan',
];
const _winnerWidths = [6.0, 9.0, 28.0, 12.0, 14.0, 30.0, 18.0, 18.0, 17.0, 18.0, 30.0];

const _summaryHeaders = ['Hadiah', 'Jenis', 'Unit', 'Pemenang sah', 'Hangus', 'Sisa'];
const _summaryWidths = [32.0, 12.0, 8.0, 14.0, 10.0, 8.0];

/// File Excel hasil undian: sheet Pemenang (termasuk yang hangus), Rekap Hadiah, dan Info.
List<int> buildWinnersWorkbook(WinnerReport report) {
  final book = xl.Excel.createExcel();
  book.rename(book.getDefaultSheet()!, 'Pemenang');

  final winners = book['Pemenang'];
  writeExcelHeader(winners, _winnerHeaders, _winnerWidths);
  writeExcelRows(
    winners,
    [
      for (final (i, row) in report.rows.indexed)
        [
          i + 1,
          row.winner.roundNo,
          row.prize.name,
          prizeKindLabel(row.prize.kind),
          row.participant.nik,
          row.participant.name,
          row.participant.area,
          row.participant.department,
          winnerStatusLabel(row.winner.status),
          formatDateTime(row.winner.drawnAt.toLocal()),
          row.winner.note,
        ],
    ],
    textColumns: const {4},
  );

  final summary = book['Rekap Hadiah'];
  writeExcelHeader(summary, _summaryHeaders, _summaryWidths);
  writeExcelRows(summary, [
    for (final s in report.summaries)
      [s.prize.name, prizeKindLabel(s.prize.kind), s.prize.quantity, s.valid, s.forfeited, s.remaining],
  ]);

  final info = book['Info'];
  info.setColumnWidth(0, 22);
  info.setColumnWidth(1, 48);
  final eventDate = report.event.eventDate;
  final lines = [
    ['Organisasi', report.organizationName],
    ['Acara', report.event.name],
    ['Tanggal acara', eventDate == null ? '-' : formatLongDate(eventDate.toLocal())],
    ['Jumlah peserta', report.participantCount],
    ['Pemenang sah', report.validRows.length],
    ['Dibuat pada', formatDateTime(report.generatedAt)],
  ];
  for (final (r, line) in lines.indexed) {
    final label = info.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r));
    label.value = xl.TextCellValue('${line[0]}');
    label.cellStyle = xl.CellStyle(bold: true);
    final value = line[1];
    info.cell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: r)).value = value is int
        ? xl.IntCellValue(value)
        : xl.TextCellValue('$value');
  }

  book.setDefaultSheet('Pemenang');
  return book.encode()!;
}
