// Membuat file contoh untuk mencoba aplikasi: 400 peserta dan 10 hadiah (data fiktif).
//
//   dart run tool/generate_sample_files.dart [folder-tujuan]
//
// Hasil (bawaan di build/contoh):
//   peserta_contoh_400.xlsx  → import lewat tab Peserta > Import Excel (format sama dengan template)
//   hadiah_contoh_10.xlsx    → daftar hadiah untuk diisi lewat tab Hadiah
//   acara_contoh.undian      → acara siap pakai (organisasi, 400 peserta, 10 hadiah) untuk
//                              Mode offline > Impor paket acara
import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:undian_client/undian_client.dart' as api;
import 'package:undian_core/undian_core.dart';
import 'package:undian_flutter/core/excel/excel_sheet.dart';
import 'package:undian_flutter/features/offline/store/offline_repository.dart';
import 'package:undian_flutter/features/offline/store/offline_storage.dart';
import 'package:undian_flutter/features/participants/import/participant_template.dart';

import 'sample_data.dart';

const organizationName = 'PT Contoh Sejahtera';
const eventName = 'Undian HUT 2026 (Contoh)';

Future<void> main(List<String> args) async {
  final folder = Directory(args.isEmpty ? 'build/contoh' : args.first)..createSync(recursive: true);
  final participants = SampleData.participants();
  final prizes = SampleData.prizes();

  _write(folder, 'peserta_contoh_400.xlsx', _participantsWorkbook(participants));
  _write(folder, 'hadiah_contoh_10.xlsx', _prizesWorkbook(prizes));
  _write(folder, 'acara_contoh.undian', await _eventPackage(participants, prizes));
}

void _write(Directory folder, String name, List<int> bytes) {
  final file = File('${folder.path}/$name')..writeAsBytesSync(bytes);
  stdout.writeln('Tersimpan: ${file.path} (${(bytes.length / 1024).toStringAsFixed(0)} KB)');
}

List<String> _sortedGroups(Prize prize) => prize.eligibleGroups.toList()..sort();

String _kindLabel(PrizeKind kind) => kind == PrizeKind.doorprize ? 'Doorprize' : 'Grand prize';

/// Sheet Peserta dengan judul kolom template, jadi kolomnya langsung dikenali saat import.
List<int> _participantsWorkbook(List<Participant> participants) {
  final book = xl.Excel.createExcel();
  book.rename(book.getDefaultSheet()!, 'Peserta');
  final sheet = book['Peserta'];
  writeExcelHeader(sheet, templateHeaders, const [16, 28, 20, 18, 18, 16, 8, 22, 22, 22]);
  writeExcelRows(
    sheet,
    [
      for (final p in participants)
        [
          p.nik,
          p.name,
          p.area,
          p.department,
          p.employmentStatus,
          '',
          p.points == 1 ? '' : p.points,
          ...(p.groups.toList()..sort()),
        ],
    ],
    textColumns: const {0},
  );
  return book.encode()!;
}

List<int> _prizesWorkbook(List<Prize> prizes) {
  final book = xl.Excel.createExcel();
  book.rename(book.getDefaultSheet()!, 'Hadiah');
  final sheet = book['Hadiah'];
  writeExcelHeader(
    sheet,
    const ['Urutan', 'Nama hadiah', 'Jenis', 'Jumlah unit', 'Grup yang berhak'],
    const [8, 30, 14, 12, 44],
  );
  writeExcelRows(sheet, [
    for (final (i, p) in prizes.indexed) [i + 1, p.name, _kindLabel(p.kind), p.quantity, _sortedGroups(p).join(', ')],
  ]);
  return book.encode()!;
}

/// Paket acara lengkap, dibuat lewat penyimpanan offline di memori.
Future<List<int>> _eventPackage(List<Participant> participants, List<Prize> prizes) async {
  final repo = await OfflineRepository.open(MemoryOfflineStorage());
  final org = await repo.createOrganization(organizationName);
  final event = await repo.createEvent(
    org.organization.id!,
    name: eventName,
    eventDate: DateTime.utc(2026, 12, 20),
    allowMultipleWins: false,
  );
  await repo.importParticipants(event.id!, [
    for (final p in participants)
      api.ParticipantInput(
        nik: p.nik,
        name: p.name,
        area: p.area,
        department: p.department,
        employmentStatus: p.employmentStatus,
        points: p.points,
        groups: p.groups.toList()..sort(),
      ),
  ], replaceAll: false);
  for (final (i, p) in prizes.indexed) {
    await repo.savePrize(
      api.EventPrize(
        eventId: event.id!,
        name: p.name,
        kind: api.PrizeKind.values.byName(p.kind.name),
        quantity: p.quantity,
        sortOrder: i + 1,
        eligibleGroups: _sortedGroups(p),
        openToAll: p.openToAll,
      ),
    );
  }
  final package = await repo.exportPackage(event.id!, exportedFrom: 'Data contoh');
  return package.encode();
}
