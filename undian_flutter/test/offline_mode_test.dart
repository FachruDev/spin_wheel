import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:undian_client/undian_client.dart';
import 'package:undian_flutter/app/fonts.dart';
import 'package:undian_flutter/core/data/repository_providers.dart';
import 'package:undian_flutter/core/data/undian_repository.dart';
import 'package:undian_flutter/features/events/event_page.dart';
import 'package:undian_flutter/features/events/events_page.dart';
import 'package:undian_flutter/features/offline/offline_providers.dart';
import 'package:undian_flutter/features/offline/store/offline_files.dart';
import 'package:undian_flutter/features/offline/store/offline_repository.dart';
import 'package:undian_flutter/features/offline/store/offline_storage.dart';
import 'package:undian_flutter/features/organizations/organizations_page.dart';

/// Laptop B dengan satu salinan otomatis berisi paket [bytes].
class _FakeFiles implements OfflineFiles {
  _FakeFiles(this.bytes);

  final List<int> bytes;

  @override
  String get deviceName => 'LAPTOP-B';

  @override
  Future<OfflineStorage> openStorage() async => MemoryOfflineStorage();

  @override
  Future<String> backupFolder() async => 'C:/salinan';

  @override
  Future<void> writeBackup(String fileName, List<int> bytes) async {}

  @override
  Future<List<BackupFile>> listBackups() async => [
    BackupFile(path: 'C:/salinan/pt_maju_hut.undian', name: 'pt_maju_hut.undian', modified: DateTime(2026, 11, 4, 9)),
  ];

  @override
  Future<List<int>> readFile(String path) async => bytes;
}

class _ActiveSession extends OfflineSession {
  _ActiveSession(this.repository);

  final UndianRepository repository;

  @override
  UndianRepository? build() => repository;
}

/// Laptop A: acara dengan 3 peserta, 1 hadiah, dan 1 pemenang; diekspor sebagai paket.
Future<List<int>> laptopAPackage() async {
  final a = await OfflineRepository.open(MemoryOfflineStorage());
  final org = await a.createOrganization('PT Maju');
  final event = await a.createEvent(org.organization.id!, name: 'HUT 2026', allowMultipleWins: false);
  await a.importParticipants(event.id!, [
    for (final (nik, name) in [('101', 'Ani Lestari'), ('102', 'Budi Santoso'), ('103', 'Citra Dewi')])
      ParticipantInput(
        nik: nik,
        name: name,
        area: 'Bogor',
        department: '',
        employmentStatus: '',
        points: 1,
        groups: [],
      ),
  ], replaceAll: false);
  final prize = await a.savePrize(
    EventPrize(
      eventId: event.id!,
      name: 'Kipas Angin',
      kind: PrizeKind.doorprize,
      quantity: 2,
      sortOrder: 1,
      eligibleGroups: [],
      openToAll: true,
    ),
  );
  await a.draw(prize.id!, 1);
  return (await a.exportPackage(event.id!, exportedFrom: 'LAPTOP-A · mode offline')).encode();
}

void main() {
  setUp(() => AppFonts.useGoogleFonts = false);

  testWidgets('laptop B: mode offline kosong → impor salinan → acara siap dengan data laptop A', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final bytes = await tester.runAsync(laptopAPackage);
    final laptopB = (await tester.runAsync(() => OfflineRepository.open(MemoryOfflineStorage())))!;
    int id(GoRouterState s, String name) => int.parse(s.pathParameters[name]!);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const OrganizationsPage(),
          routes: [
            GoRoute(
              path: 'o/:org',
              builder: (_, s) => EventsPage(organizationId: id(s, 'org')),
              routes: [
                GoRoute(
                  path: 'a/:event',
                  builder: (_, s) => EventPage(organizationId: id(s, 'org'), eventId: id(s, 'event')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offlineSessionProvider.overrideWith(() => _ActiveSession(laptopB)),
          offlineFilesProvider.overrideWithValue(_FakeFiles(bytes!)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mode offline'), findsOneWidget);
    expect(find.text('Belum ada data di laptop ini'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('import-package-open')));
    await tester.pumpAndSettle();
    expect(find.text('PT Maju – HUT 2026'), findsOneWidget);
    expect(find.textContaining('3 peserta · 1 hadiah (2 unit) · 1 pemenang'), findsOneWidget);

    await tester.tap(find.text('PT Maju – HUT 2026'));
    await tester.pumpAndSettle();
    expect(find.text('LAPTOP-A · mode offline'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('import-package')));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    // Halaman acara hasil impor: nama acara, keterangan asal, dan peserta dari laptop A.
    expect(find.text('HUT 2026'), findsOneWidget);
    expect(find.textContaining('Paket dari LAPTOP-A · mode offline'), findsOneWidget);
    expect(find.text('Ani Lestari'), findsOneWidget);
    expect(find.text('Citra Dewi'), findsOneWidget);
    expect(find.byKey(const ValueKey('export-package')), findsOneWidget);
    expect(find.text('Buka panggung'), findsOneWidget);
  });
}
