// Uji ujung-ke-ujung dengan server lokal yang sedang berjalan. Contoh menjalankan:
//
//   flutter test integration_test/e2e_test.dart -d windows \
//     --dart-define=SERVER_URL=http://localhost:8080/ \
//     --dart-define=SERVER_LOG=C:/path/ke/log-server.txt
//
// SERVER_LOG adalah file keluaran `dart bin/main.dart`; kode verifikasi pendaftaran dibaca dari sana.
import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:undian_client/undian_client.dart';
import 'package:undian_flutter/app/app.dart';
import 'package:undian_flutter/app/fonts.dart';
import 'package:undian_flutter/core/server/server_providers.dart';
import 'package:undian_flutter/features/events/event_page.dart';
import 'package:undian_flutter/features/offline/offline_providers.dart';
import 'package:undian_flutter/features/offline/package/event_package.dart';
import 'package:undian_flutter/features/offline/store/offline_files_io.dart';
import 'package:undian_flutter/features/offline/store/offline_repository.dart';
import 'package:undian_flutter/features/participants/import/import_dialog.dart';
import 'package:undian_flutter/features/participants/participants_tab.dart';

const serverLog = String.fromEnvironment('SERVER_LOG');

Future<void> pumpUntil(WidgetTester tester, Finder finder, {int seconds = 20}) async {
  final end = DateTime.now().add(Duration(seconds: seconds));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Tidak muncul dalam $seconds detik: $finder');
}

Future<String> registrationCode(String email) async {
  final pattern = RegExp('Registration code \\(${RegExp.escape(email)}\\): (\\S+)');
  final end = DateTime.now().add(const Duration(seconds: 15));
  while (DateTime.now().isBefore(end)) {
    final match = pattern.allMatches(await File(serverLog).readAsString()).lastOrNull;
    if (match != null) return match.group(1)!;
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
  throw TestFailure('Kode verifikasi untuk $email tidak ada di $serverLog');
}

/// 30 peserta: 20 di Bogor (14 tetap → ikut grand prize), 10 di Jakarta.
List<int> participantWorkbook() {
  final book = xl.Excel.createExcel();
  final sheet = book[book.getDefaultSheet()!];
  sheet.appendRow([
    for (final h in ['No', 'No. Karyawan', 'Nama Karyawan', 'Lokasi Kerja', 'Cost Center', 'Status Karyawan', '', ''])
      xl.TextCellValue(h),
  ]);
  for (var i = 1; i <= 30; i++) {
    final bogor = i <= 20;
    final permanent = i % 3 != 0;
    final area = bogor ? 'Bogor' : 'Jakarta';
    sheet.appendRow([
      xl.IntCellValue(i),
      xl.TextCellValue('2600${i.toString().padLeft(4, '0')}'),
      xl.TextCellValue('Peserta Uji $i'),
      xl.TextCellValue(bogor ? 'Bogor Plant' : 'Head Office'),
      xl.TextCellValue('ICT'),
      xl.TextCellValue(permanent ? 'Pegawai Tetap' : 'Kontrak 1'),
      xl.TextCellValue('Doorprize $area'),
      if (permanent) xl.TextCellValue('Grandprize $area'),
    ]);
  }
  return book.encode()!;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('daftar → organisasi → acara → import → hadiah → undi → server mati → lanjut offline', (tester) async {
    expect(serverLog, isNotEmpty, reason: 'jalankan dengan --dart-define=SERVER_LOG=...');
    AppFonts.useGoogleFonts = false;
    final client = await createClient();
    await client.auth.signOutDevice();
    // Data offline dan salinan otomatis di folder sementara, bukan di data aplikasi laptop ini.
    final tempDir = await Directory.systemTemp.createTemp('undian_e2e');
    addTearDown(() => tempDir.delete(recursive: true));
    final offlineFiles = IoOfflineFiles(baseDirectory: () async => Directory('${tempDir.path}/laptop_a'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [clientProvider.overrideWithValue(client), offlineFilesProvider.overrideWithValue(offlineFiles)],
        child: const UndianApp(),
      ),
    );
    await pumpUntil(tester, find.text('Belum punya akun? Daftar'));

    // Daftar akun baru.
    final email = 'panitia.${DateTime.now().millisecondsSinceEpoch}@contoh.test';
    await tester.tap(find.text('Belum punya akun? Daftar'));
    await pumpUntil(tester, find.text('Kirim kode'));
    await tester.enterText(find.byType(TextField), email);
    await tester.pump();
    await tester.tap(find.text('Kirim kode'));
    await pumpUntil(tester, find.text('Verifikasi'));
    final code = await registrationCode(email);
    await tester.enterText(find.byType(TextField), code);
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, code);
    await tester.tap(find.text('Verifikasi'));
    await pumpUntil(tester, find.text('Buat akun'));
    await tester.enterText(find.byType(TextField), 'Uji-${DateTime.now().millisecondsSinceEpoch}-Aman');
    await tester.pump();
    await tester.tap(find.text('Buat akun'));
    await pumpUntil(tester, find.text('Belum ada organisasi'));

    // Organisasi dan acara.
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Buat organisasi'));
    await pumpUntil(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'PT Uji Coba');
    await tester.pump();
    await tester.tap(find.text('Simpan'));
    await pumpUntil(tester, find.text('Belum ada acara'));
    await tester.pump(const Duration(seconds: 1)); // tunggu transisi halaman selesai
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Buat acara'));
    await pumpUntil(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'HUT Uji 2026');
    await tester.pump();
    await tester.tap(find.text('Buat'));
    await pumpUntil(tester, find.text('Belum ada peserta'));

    // Import Excel lewat dialog yang sama dengan yang dipakai panitia.
    final eventId = tester.widget<ParticipantsTab>(find.byType(ParticipantsTab)).eventId;
    showDialog<void>(
      context: tester.element(find.byType(ParticipantsTab)),
      builder: (_) => ImportDialog(
        eventId: eventId,
        hasWinners: false,
        initialFile: (name: 'peserta.xlsx', bytes: participantWorkbook()),
      ),
    );
    await pumpUntil(tester, find.text('Import 30 peserta'));
    await tester.tap(find.text('Import 30 peserta'));
    await pumpUntil(tester, find.text('Import selesai'));
    expect(find.textContaining('30 peserta baru'), findsOneWidget);
    await tester.tap(find.text('Selesai'));
    await pumpUntil(tester, find.text('30 dari 30 peserta'));

    // Hadiah: 10 voucher untuk Doorprize Bogor, 1 motor untuk Grandprize Bogor.
    await tester.tap(find.text('Hadiah'));
    await pumpUntil(tester, find.text('Belum ada hadiah'));
    await tester.pump(const Duration(seconds: 1)); // tunggu animasi geser tab selesai
    Future<void> addPrize(String name, String quantity, String group, {bool grand = false}) async {
      await tester.tap(find.text('Tambah hadiah').first);
      await pumpUntil(tester, find.text('Nama hadiah'));
      await tester.enterText(find.widgetWithText(TextField, 'Nama hadiah'), name);
      await tester.pump();
      await tester.enterText(find.widgetWithText(TextField, 'Jumlah unit'), quantity);
      await tester.pump();
      if (grand) await tester.tap(find.text('Grand prize'));
      await tester.tap(find.textContaining('$group ('));
      await tester.pump();
      await tester.tap(find.text('Simpan'));
      await pumpUntil(tester, find.text(name));
    }

    await addPrize('Voucher Uji', '10', 'Doorprize Bogor');
    await addPrize('Motor Uji', '1', 'Grandprize Bogor', grand: true);

    // Panggung: undi 10 voucher (Kartu), lalu motor (Panggung Utama).
    await tester.tap(find.text('Buka panggung'));
    await pumpUntil(tester, find.text('HADIAH BERIKUTNYA'));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await pumpUntil(tester, find.text('LANJUT  (Spasi)'), seconds: 30);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Motor Uji'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await pumpUntil(tester, find.text('LANJUT  (Spasi)'), seconds: 40);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await pumpUntil(tester, find.text('Buka panggung'));

    // Pemenang tersimpan di server dan tampil di tab Pemenang.
    await tester.tap(find.text('Pemenang'));
    await pumpUntil(tester, find.text('11 pemenang sah · 0 hangus'));
    await tester.pump(const Duration(seconds: 1)); // tunggu animasi geser tab selesai
    expect(find.text('Export Excel'), findsOneWidget);
    expect(find.text('Export PDF'), findsOneWidget);
    final winners = await client.draw.winners(eventId);
    final participants = {for (final p in await client.participant.list(eventId)) p.id: p};
    expect(winners, hasLength(11));
    expect(winners.map((w) => w.participantId).toSet(), hasLength(11), reason: 'tidak ada yang menang dua kali');
    final prizes = {for (final p in await client.prize.list(eventId)) p.id: p.name};
    for (final w in winners) {
      final groups = participants[w.participantId]!.groups;
      final expected = prizes[w.prizeId] == 'Motor Uji' ? 'Grandprize Bogor' : 'Doorprize Bogor';
      expect(groups, contains(expected), reason: 'pemenang ${prizes[w.prizeId]} harus dari grup $expected');
      expect(w.status, WinnerStatus.sah);
    }

    // --- Server bermasalah: laptop ini lanjut di mode offline dari salinan otomatis. ---------
    await pumpUntil(tester, find.textContaining('Salinan offline '), seconds: 15);
    final backups = await offlineFiles.listBackups();
    expect(backups, hasLength(1));
    final backup = EventPackage.decode(await offlineFiles.readFile(backups.single.path));
    expect(backup.activeWinnerCount, 11, reason: 'salinan otomatis sudah memuat hasil undian terakhir');

    await client.auth.signOutDevice();
    await pumpUntil(tester, find.byKey(const ValueKey('offline-mode')));
    await tester.tap(find.byKey(const ValueKey('offline-mode')));
    await pumpUntil(tester, find.text('Belum ada data di laptop ini'));
    await tester.tap(find.byKey(const ValueKey('import-package-open')));
    await pumpUntil(tester, find.text('PT Uji Coba – HUT Uji 2026'));
    await tester.tap(find.text('PT Uji Coba – HUT Uji 2026'));
    await pumpUntil(tester, find.byKey(const ValueKey('import-package')));
    await tester.tap(find.byKey(const ValueKey('import-package')));
    await pumpUntil(tester, find.textContaining('Data tersimpan di laptop ini'));
    await tester.tap(find.text('Pemenang'));
    await pumpUntil(tester, find.text('11 pemenang sah · 0 hangus'));
    await tester.pump(const Duration(seconds: 1));

    // Satu pemenang voucher hangus, lalu unitnya diundi ulang di panggung offline.
    final container = ProviderScope.containerOf(tester.element(find.byType(EventPage)));
    final offline = container.read(activeOfflineRepositoryProvider)!;
    final offlineEventId = tester.widget<EventPage>(find.byType(EventPage)).eventId;
    final offlinePrizes = {for (final p in await offline.prizes(offlineEventId)) p.name: p.id};
    final voucherWinner = (await offline.winners(
      offlineEventId,
    )).firstWhere((w) => w.prizeId == offlinePrizes['Voucher Uji']);
    await offline.setWinnerStatus(voucherWinner.id!, WinnerStatus.hangus, 'Tidak hadir');
    await tester.tap(find.text('Buka panggung'));
    await pumpUntil(tester, find.text('HADIAH BERIKUTNYA'));
    // Voucher (sisa 1 unit) sudah otomatis jadi hadiah berikutnya: judul besar + item di panel operator.
    expect(find.text('Voucher Uji'), findsNWidgets(2));
    await tester.tap(find.text('Voucher Uji').last);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await pumpUntil(tester, find.text('LANJUT  (Spasi)'), seconds: 30);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await pumpUntil(tester, find.text('Buka panggung'));
    await tester.tap(find.text('Pemenang'));
    await pumpUntil(tester, find.text('11 pemenang sah · 1 hangus'));

    // Data offline tersimpan di file, dan server tidak tersentuh.
    final reopened = await OfflineRepository.open(await offlineFiles.openStorage());
    final offlineWinners = await reopened.winners(offlineEventId);
    expect(offlineWinners, hasLength(12));
    final redrawn = offlineWinners.last;
    expect(redrawn.participantId, isNot(voucherWinner.participantId));
    expect(redrawn.roundNo, 3);
    // Perubahan offline tidak memicu salinan otomatis server: salinan tetap berisi data server (11).
    final backupAfter = EventPackage.decode(await offlineFiles.readFile(backups.single.path));
    expect(backupAfter.winners, hasLength(11));

    // Laptop B: impor paket dari laptop ini dan dapat data yang sama persis.
    final package = await offline.exportPackage(offlineEventId, exportedFrom: 'LAPTOP-A · mode offline');
    final laptopB = await OfflineRepository.open(
      await IoOfflineFiles(baseDirectory: () async => Directory('${tempDir.path}/laptop_b')).openStorage(),
    );
    final onB = await laptopB.importPackage(EventPackage.decode(package.encode()));
    final winnersB = await laptopB.winners(onB.id!);
    expect(winnersB.where((w) => w.status == WinnerStatus.sah), hasLength(11));
    expect(winnersB.where((w) => w.status == WinnerStatus.hangus).single.note, 'Tidak hadir');
  });
}
