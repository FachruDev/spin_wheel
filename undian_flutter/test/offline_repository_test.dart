import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:undian_client/undian_client.dart';
import 'package:undian_flutter/features/offline/package/event_package.dart';
import 'package:undian_flutter/features/offline/store/offline_data.dart';
import 'package:undian_flutter/features/offline/store/offline_repository.dart';
import 'package:undian_flutter/features/offline/store/offline_storage.dart';

/// Laptop dengan satu organisasi, satu acara, 6 peserta, dan 2 hadiah.
Future<({OfflineRepository repo, MemoryOfflineStorage storage, int orgId, int eventId})> seeded() async {
  final storage = MemoryOfflineStorage();
  final repo = await OfflineRepository.open(storage);
  final org = await repo.createOrganization('PT Maju');
  final event = await repo.createEvent(org.organization.id!, name: 'HUT 2026', allowMultipleWins: false);
  await repo.importParticipants(event.id!, [
    for (var i = 1; i <= 6; i++)
      ParticipantInput(
        nik: 'N$i',
        name: 'Peserta $i',
        area: i <= 3 ? 'Bogor' : 'Jakarta',
        department: 'Produksi',
        employmentStatus: 'Tetap',
        points: i == 1 ? 3 : 1,
        groups: [i <= 3 ? 'Doorprize Bogor' : 'Doorprize Jakarta'],
      ),
  ], replaceAll: false);
  await repo.savePrize(
    EventPrize(
      eventId: event.id!,
      name: 'Kipas',
      kind: PrizeKind.doorprize,
      quantity: 2,
      sortOrder: 1,
      eligibleGroups: ['Doorprize Bogor'],
      openToAll: false,
    ),
  );
  await repo.savePrize(
    EventPrize(
      eventId: event.id!,
      name: 'Motor',
      kind: PrizeKind.grandprize,
      quantity: 1,
      sortOrder: 2,
      eligibleGroups: [],
      openToAll: true,
    ),
  );
  return (repo: repo, storage: storage, orgId: org.organization.id!, eventId: event.id!);
}

void main() {
  group('data offline', () {
    test('tersimpan setiap perubahan dan terbaca ulang utuh', () async {
      final s = await seeded();
      final reopened = await OfflineRepository.open(MemoryOfflineStorage(s.storage.contents));
      expect((await reopened.myOrganizations()).single.organization.name, 'PT Maju');
      expect((await reopened.myOrganizations()).single.role, MemberRole.admin);
      expect(await reopened.participants(s.eventId), hasLength(6));
      expect((await reopened.prizes(s.eventId)).map((p) => p.name), ['Kipas', 'Motor']);
      expect(reopened.eventInfo(s.eventId)!.origin, 'Dibuat di mode offline');
    });

    test('file utama rusak: salinan sebelumnya yang dipakai', () async {
      final s = await seeded();
      final storage = MemoryOfflineStorage('{rusak')..previous = s.storage.contents;
      final reopened = await OfflineRepository.open(storage);
      expect(await reopened.participants(s.eventId), hasLength(6));
    });

    test('import peserta: tambah, perbarui, tolak, dan ganti total diblokir setelah ada pemenang', () async {
      final s = await seeded();
      final result = await s.repo.importParticipants(s.eventId, [
        ParticipantInput(
          nik: 'N1',
          name: 'Peserta Satu',
          area: 'Bogor',
          department: '',
          employmentStatus: '',
          points: 2,
          groups: ['Doorprize Bogor'],
        ),
        ParticipantInput(
          nik: 'N7',
          name: 'Peserta 7',
          area: '',
          department: '',
          employmentStatus: '',
          points: 1,
          groups: [],
        ),
        ParticipantInput(
          nik: '',
          name: 'Tanpa NIK',
          area: '',
          department: '',
          employmentStatus: '',
          points: 1,
          groups: [],
        ),
      ], replaceAll: false);
      expect((result.inserted, result.updated), (1, 1));
      expect(result.rejected, ['Baris 3: NIK kosong']);
      final n1 = (await s.repo.participants(s.eventId)).firstWhere((p) => p.nik == 'N1');
      expect((n1.name, n1.points), ('Peserta Satu', 2));

      final kipas = (await s.repo.prizes(s.eventId)).first;
      await s.repo.draw(kipas.id!, 1);
      expect(
        () => s.repo.importParticipants(s.eventId, const [], replaceAll: true),
        throwsA(isA<UndianException>().having((e) => e.message, 'message', contains('sudah punya pemenang'))),
      );
    });
  });

  group('undian offline', () {
    test('pemenang dari grup yang berhak, tercatat per putaran, dan tidak menang dua kali', () async {
      final s = await seeded();
      final prizes = await s.repo.prizes(s.eventId);
      final kipas = prizes.first, motor = prizes.last;

      final first = await s.repo.draw(kipas.id!, 2);
      expect(first.roundNo, 1);
      expect(first.poolSize, 3);
      expect(first.winners.every((p) => p.groups.contains('Doorprize Bogor')), isTrue);
      expect(first.winnerRecords.every((w) => w.status == WinnerStatus.sah), isTrue);

      expect(
        () => s.repo.draw(kipas.id!, 1),
        throwsA(isA<UndianException>().having((e) => e.message, 'message', 'Stok Kipas tinggal 0 unit.')),
      );

      final second = await s.repo.draw(motor.id!, 1);
      expect(second.roundNo, 2);
      expect(second.poolSize, 4, reason: 'dua pemenang kipas tidak ikut lagi');
      expect(await s.repo.winners(s.eventId), hasLength(3));
    });

    test('hangus wajib beralasan, mengembalikan stok, dan final', () async {
      final s = await seeded();
      final kipas = (await s.repo.prizes(s.eventId)).first;
      final result = await s.repo.draw(kipas.id!, 2);
      final winner = result.winnerRecords.first;

      expect(() => s.repo.setWinnerStatus(winner.id!, WinnerStatus.hangus, ' '), throwsA(isA<UndianException>()));
      await s.repo.setWinnerStatus(winner.id!, WinnerStatus.hangus, 'Tidak hadir');
      expect(
        () => s.repo.setWinnerStatus(winner.id!, WinnerStatus.sah, null),
        throwsA(isA<UndianException>().having((e) => e.message, 'message', contains('sudah hangus'))),
      );

      final redraw = await s.repo.draw(kipas.id!, 1);
      expect(redraw.winners.single.id, isNot(winner.participantId), reason: 'pemenang hangus tidak ikut lagi');
    });

    test('aturan hadiah sama dengan server', () async {
      final s = await seeded();
      final kipas = (await s.repo.prizes(s.eventId)).first;
      await s.repo.draw(kipas.id!, 2);
      expect(() => s.repo.savePrize(kipas.copyWith(quantity: 1)), throwsA(isA<UndianException>()));
      expect(() => s.repo.deletePrize(kipas), throwsA(isA<UndianException>()));
      expect(
        () => s.repo.savePrize(kipas.copyWith(id: null, eligibleGroups: [], openToAll: false)),
        throwsA(isA<UndianException>().having((e) => e.message, 'message', contains('minimal satu grup'))),
      );
      expect(() => s.repo.draw(kipas.id!, 51), throwsA(isA<UndianException>()));
    });
  });

  group('paket acara: laptop A ke laptop B', () {
    test('paket membawa semua data dan undian berlanjut di laptop B', () async {
      final a = await seeded();
      final prizes = await a.repo.prizes(a.eventId);
      final drawn = await a.repo.draw(prizes.first.id!, 2);
      await a.repo.setWinnerStatus(drawn.winnerRecords.first.id!, WinnerStatus.diserahkan, null);

      final package = await a.repo.exportPackage(a.eventId, exportedFrom: 'LAPTOP-A · mode offline');
      final bytes = package.encode();

      // Laptop B: aplikasi baru, belum ada data.
      final b = await OfflineRepository.open(MemoryOfflineStorage());
      final imported = await b.importPackage(EventPackage.decode(bytes));
      final org = (await b.myOrganizations()).single.organization;
      expect(org.name, 'PT Maju');
      expect(imported.organizationId, org.id);
      expect(await b.participants(imported.id!), hasLength(6));

      final winners = await b.winners(imported.id!);
      final participants = {for (final p in await b.participants(imported.id!)) p.id: p.nik};
      final nikA = {for (final w in drawn.winners) w.nik};
      expect({for (final w in winners) participants[w.participantId]}, nikA, reason: 'id dipetakan ulang dengan benar');
      expect(winners.map((w) => w.status), containsAll([WinnerStatus.diserahkan, WinnerStatus.sah]));

      // Stok dan kelayakan ikut terbawa: kipas habis, pemenang kipas tidak ikut undian motor.
      final prizesB = await b.prizes(imported.id!);
      expect(() => b.draw(prizesB.first.id!, 1), throwsA(isA<UndianException>()));
      final motor = await b.draw(prizesB.last.id!, 1);
      expect(nikA.contains(motor.winners.single.nik), isFalse);
      expect(motor.roundNo, 2);
      expect(b.eventInfo(imported.id!)!.origin, 'Paket dari LAPTOP-A · mode offline');
    });

    test('impor ulang: bisa mengganti salinan lama atau disimpan terpisah', () async {
      final a = await seeded();
      final first = await a.repo.exportPackage(a.eventId, exportedFrom: 'LAPTOP-A · mode offline');
      final b = await OfflineRepository.open(MemoryOfflineStorage());
      final old = await b.importPackage(first);
      expect(b.eventsWithLineage(first.lineageId).map((e) => e.id), [old.id]);

      final kipas = (await a.repo.prizes(a.eventId)).first;
      await a.repo.draw(kipas.id!, 1);
      final second = await a.repo.exportPackage(a.eventId, exportedFrom: 'LAPTOP-A · mode offline');
      expect(second.lineageId, first.lineageId);

      final replaced = await b.importPackage(second, replaceEventId: old.id);
      expect(b.eventsWithLineage(second.lineageId).map((e) => e.id), [replaced.id]);
      expect(await b.winners(replaced.id!), hasLength(1));
      expect(await b.participants(replaced.id!), hasLength(6), reason: 'data acara lama tidak tersisa');

      await b.importPackage(second);
      expect(b.eventsWithLineage(second.lineageId), hasLength(2));
      expect(await b.myOrganizations(), hasLength(1), reason: 'organisasi dengan nama sama dipakai ulang');
    });

    test('file yang bukan paket atau rusak ditolak dengan pesan jelas', () async {
      final a = await seeded();
      final good = jsonDecode(utf8.decode((await a.repo.exportPackage(a.eventId, exportedFrom: 'A')).encode())) as Map;

      Matcher fails(String text) => throwsA(isA<UndianException>().having((e) => e.message, 'message', contains(text)));
      expect(() => EventPackage.decode(utf8.encode('bukan json')), fails('bukan paket acara'));
      expect(() => EventPackage.decode(utf8.encode(jsonEncode({'format': 'lain'}))), fails('bukan paket acara'));
      expect(() => EventPackage.decode(utf8.encode(jsonEncode({...good, 'version': 99}))), fails('versi aplikasi'));
      expect(() => EventPackage.decode(utf8.encode(jsonEncode({...good, 'event': null}))), fails('rusak'));

      final winners = [
        {
          ...((good['winners'] as List).isEmpty ? _fakeWinner(good) : (good['winners'] as List).first),
          'participantId': 999999,
        },
      ];
      expect(
        () => EventPackage.decode(utf8.encode(jsonEncode({...good, 'winners': winners}))),
        fails('tidak konsisten'),
      );
    });

    test('paket dari server mencatat sumbernya', () {
      const source = PackageSource(serverUrl: 'https://api.contoh.id/', organizationId: 3, eventId: 7);
      expect(source.lineageId, 'server:https://api.contoh.id/#7');
      expect(PackageSource.fromJson(source.toJson()).lineageId, source.lineageId);
    });
  });
}

Map<String, dynamic> _fakeWinner(Map good) => {
  'eventId': (good['event'] as Map)['id'],
  'prizeId': ((good['prizes'] as List).first as Map)['id'],
  'participantId': 0,
  'roundNo': 1,
  'status': 'sah',
  'drawnAt': DateTime.now().toUtc().toIso8601String(),
  'drawnBy': randomUuid(),
};
