import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:undian_client/undian_client.dart';
import 'package:undian_flutter/features/participants/import/excel_table_reader.dart';
import 'package:undian_flutter/features/winners/export/winner_report.dart';
import 'package:undian_flutter/features/winners/export/winners_excel.dart';
import 'package:undian_flutter/features/winners/export/winners_pdf.dart';

/// Isi dengan `--dart-define=EXPORT_SAMPLES=folder` untuk menyimpan contoh file hasil export.
const _samplesDir = String.fromEnvironment('EXPORT_SAMPLES');

EventParticipant person(int id, String nik, String name, String area) => EventParticipant(
  id: id,
  eventId: 1,
  nik: nik,
  name: name,
  area: area,
  department: 'Produksi',
  employmentStatus: 'Pegawai Tetap',
  points: 1,
  groups: const ['Doorprize'],
);

PrizeWinner winner(int id, int prizeId, int participantId, int round, [WinnerStatus status = WinnerStatus.sah]) =>
    PrizeWinner(
      id: id,
      eventId: 1,
      prizeId: prizeId,
      participantId: participantId,
      roundNo: round,
      status: status,
      drawnAt: DateTime.utc(2026, 11, 3, 12),
      drawnBy: UuidValue.fromString('01a19fef-834e-7981-aa21-0ccbe9d3e43f'),
      note: status == WinnerStatus.hangus ? 'Tidak hadir' : null,
    );

WinnerReport sampleReport() => WinnerReport(
  organizationName: 'PT Maju Bersama',
  event: DrawEvent(
    id: 1,
    organizationId: 1,
    name: 'HUT 2026',
    eventDate: DateTime.utc(2026, 11, 3),
    allowMultipleWins: false,
    createdAt: DateTime.utc(2026, 10, 1),
  ),
  prizes: [
    EventPrize(
      id: 20,
      eventId: 1,
      name: 'Sepeda Motor',
      kind: PrizeKind.grandprize,
      quantity: 1,
      sortOrder: 2,
      eligibleGroups: const ['Doorprize'],
      openToAll: false,
    ),
    EventPrize(
      id: 10,
      eventId: 1,
      name: 'Voucher Belanja',
      kind: PrizeKind.doorprize,
      quantity: 3,
      sortOrder: 1,
      eligibleGroups: const ['Doorprize'],
      openToAll: false,
    ),
  ],
  participants: [
    person(1, '03090234', 'Andi Pratama', 'Bogor Plant'),
    person(2, '04090246', 'Siti Rahmawati', 'Head Office'),
    person(3, '16063404', 'Budi Santoso', 'Head Office'),
    person(4, '21104567', 'Ūmar Ḥasan 李', 'Bogor Plant'),
  ],
  winners: [
    winner(4, 20, 4, 2),
    winner(1, 10, 1, 1),
    winner(2, 10, 2, 1, WinnerStatus.hangus),
    winner(3, 10, 3, 1, WinnerStatus.diserahkan),
  ],
  generatedAt: DateTime(2026, 11, 3, 15, 30),
);

void main() {
  test('laporan: urut per rundown hadiah, rekap, dan pengelompokan per area', () {
    final report = sampleReport();
    expect(report.rows.map((r) => r.prize.name), [
      'Voucher Belanja',
      'Voucher Belanja',
      'Voucher Belanja',
      'Sepeda Motor',
    ]);
    expect(report.validRows, hasLength(3));
    final voucher = report.summaries.first;
    expect((voucher.valid, voucher.forfeited, voucher.remaining), (2, 1, 1));
    expect(report.validRowsByArea.keys, ['Bogor Plant', 'Head Office']);
    expect(report.validRowsByArea['Head Office']!.map((r) => r.participant.name), ['Budi Santoso']);
    expect(report.fileName('pemenang', 'xlsx'), 'pemenang_hut_2026.xlsx');
  });

  test('Excel: sheet Pemenang, Rekap Hadiah, Info; NIK tetap teks', () {
    final sheets = readWorkbook(buildWinnersWorkbook(sampleReport()));
    expect(sheets.map((s) => s.name), ['Pemenang', 'Rekap Hadiah', 'Info']);
    final winners = sheets.first.table();
    expect(winners.headers.take(6), ['No', 'Putaran', 'Hadiah', 'Jenis', 'NIK', 'Nama']);
    expect(winners.rows, hasLength(4));
    expect(winners.rows.first.cells[4], '03090234');
    expect(winners.rows[1].cells[8], 'Hangus');
    final summary = sheets[1].table();
    expect(summary.rows.first.cells, ['Voucher Belanja', 'Doorprize', '3', '2', '1', '0', '1']);
  });

  test('teks PDF: diakritik jadi huruf dasar, aksara non-Latin jadi tanda tanya', () {
    expect(pdfSafeText('Ūmar Ḥasan – Łukasz'), 'Umar Hasan - Lukasz');
    expect(pdfSafeText('José Müller'), 'José Müller', reason: 'huruf Latin-1 tetap');
    expect(pdfSafeText('李'), '?');
  });

  for (final kind in WinnerPdfKind.values) {
    test('PDF ${kind.label}: terbentuk, termasuk nama dengan huruf non-Latin', () async {
      final bytes = await buildWinnersPdf(sampleReport(), kind);
      expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
      final pages = RegExp(r'/Type\s*/Page[^s]').allMatches(latin1.decode(bytes)).length;
      expect(pages, kind == WinnerPdfKind.tandaTerima ? 2 : 1, reason: 'tanda terima: satu halaman per area');
      if (_samplesDir.isNotEmpty) {
        File('$_samplesDir/${kind.filePrefix}.pdf')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes);
      }
    });
  }
}
