import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undian_client/undian_client.dart';
import 'package:undian_flutter/app/fonts.dart';
import 'package:undian_flutter/core/data/repository_providers.dart';
import 'package:undian_flutter/core/data/undian_repository.dart';
import 'package:undian_flutter/features/events/events_page.dart';
import 'package:undian_flutter/features/offline/store/offline_repository.dart';
import 'package:undian_flutter/features/offline/store/offline_storage.dart';
import 'package:undian_flutter/features/participants/participants_tab.dart';
import 'package:undian_flutter/features/winners/winners_tab.dart';

class _ActiveSession extends OfflineSession {
  _ActiveSession(this.repository);

  final UndianRepository repository;

  @override
  UndianRepository? build() => repository;
}

typedef _Setup = ({OfflineRepository repo, int orgId, int eventId});

/// Acara kosong di penyimpanan offline (memori). Dibuat di zona tes (bukan runAsync), supaya
/// penyimpanan berantai di repositori ikut berjalan saat pump.
Future<_Setup> _setup(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repo = await OfflineRepository.open(MemoryOfflineStorage());
  final org = await repo.createOrganization('PT Maju');
  final event = await repo.createEvent(org.organization.id!, name: 'HUT 2026', allowMultipleWins: false);
  return (repo: repo, orgId: org.organization.id!, eventId: event.id!);
}

Widget _app(UndianRepository repo, Widget home) => ProviderScope(
  overrides: [offlineSessionProvider.overrideWith(() => _ActiveSession(repo))],
  child: MaterialApp(home: home),
);

ParticipantInput _row(String nik, String name) => ParticipantInput(
  nik: nik,
  name: name,
  area: 'Bogor',
  department: '',
  employmentStatus: '',
  points: 1,
  groups: ['Doorprize'],
);

void main() {
  setUp(() => AppFonts.useGoogleFonts = false);

  testWidgets('peserta: tambah lewat formulir, NIK ganda ditolak, ubah, lalu hapus', (tester) async {
    final s = await _setup(tester);
    await tester.pumpWidget(_app(s.repo, Scaffold(body: ParticipantsTab(eventId: s.eventId, canManage: true))));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada peserta'), findsOneWidget);

    Future<void> fillNew(String nik, String name) async {
      await tester.tap(find.byKey(const ValueKey('add-participant')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('participant-nik')), nik);
      await tester.enterText(find.byKey(const ValueKey('participant-name')), name);
      await tester.pump();
    }

    await fillNew('101', 'Ani Lestari');
    await tester.enterText(find.widgetWithText(TextField, 'Grup lain'), 'Doorprize Bogor');
    await tester.tap(find.text('Tambah'));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('participant-save')));
    await tester.pumpAndSettle();
    expect(find.text('Ani Lestari'), findsOneWidget);
    expect(find.text('Doorprize Bogor · 1'), findsOneWidget);

    await fillNew('101', 'Ani Kembar');
    await tester.tap(find.byKey(const ValueKey('participant-save')));
    await tester.pumpAndSettle();
    expect(find.text('NIK 101 sudah terdaftar di acara ini.'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ani Lestari'));
    await tester.pumpAndSettle();
    expect(find.text('Ubah peserta'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('participant-name')), 'Ani Lestari Putri');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('participant-save')));
    await tester.pumpAndSettle();
    expect(find.text('Ani Lestari Putri'), findsOneWidget);

    await tester.tap(find.text('Ani Lestari Putri'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('participant-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada peserta'), findsOneWidget);
  });

  testWidgets('acara bisa diubah lewat menu di daftar acara', (tester) async {
    final s = await _setup(tester);
    await tester.pumpWidget(_app(s.repo, EventsPage(organizationId: s.orgId)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ValueKey('event-menu-${s.eventId}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ubah acara'));
    await tester.pumpAndSettle();
    expect(find.text('Ubah acara'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('event-name')), 'HUT ke-50');
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.textContaining('Berlaku untuk undian berikutnya'), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('HUT ke-50'), findsOneWidget);
    expect(find.textContaining('boleh menang lebih dari sekali'), findsOneWidget);
    final saved = (await s.repo.events(s.orgId)).single;
    expect((saved.name, saved.allowMultipleWins), ('HUT ke-50', true));
  });

  testWidgets('pemenang bisa didiskualifikasi dari satu hadiah dengan alasan', (tester) async {
    final s = await _setup(tester);
    await s.repo.importParticipants(s.eventId, [_row('101', 'Ani'), _row('102', 'Budi')], replaceAll: false);
    final prize = await s.repo.savePrize(
      EventPrize(
        eventId: s.eventId,
        name: 'Kipas Angin',
        kind: PrizeKind.doorprize,
        quantity: 1,
        sortOrder: 1,
        eligibleGroups: ['Doorprize'],
        openToAll: false,
      ),
    );
    await s.repo.draw(prize.id!, 1);
    final event = (await s.repo.events(s.orgId)).single;
    await tester.pumpWidget(_app(s.repo, Scaffold(body: WinnersTab(event: event, organization: null, canDraw: true))));
    await tester.pumpAndSettle();
    expect(find.text('1 pemenang sah · 0 hangus'), findsOneWidget);

    await tester.tap(find.byTooltip('Ubah status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diskualifikasi dari hadiah ini'));
    await tester.pumpAndSettle();
    expect(find.textContaining('dari Kipas Angin?'), findsOneWidget);
    await tester.tap(find.text('Diskualifikasi'));
    await tester.pumpAndSettle();

    expect(find.text('0 pemenang sah · 0 hangus · 1 didiskualifikasi'), findsOneWidget);
    expect(find.text('Didiskualifikasi'), findsOneWidget);
    expect(find.byTooltip('Ubah status'), findsNothing, reason: 'status final tidak bisa diubah lagi');
    final winner = (await s.repo.winners(s.eventId)).single;
    expect((winner.status, winner.note), (WinnerStatus.diskualifikasi, 'Tidak memenuhi syarat hadiah ini'));
  });
}
