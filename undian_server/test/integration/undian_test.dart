import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';
import 'package:undian_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

ParticipantInput row(String nik, String name, {List<String> groups = const ['Doorprize'], int points = 1}) =>
    ParticipantInput(
      nik: nik,
      name: name,
      area: 'Bogor Plant',
      department: 'ICT',
      employmentStatus: 'Pegawai Tetap',
      points: points,
      groups: groups,
    );

void main() {
  withServerpod('Undian', (sessionBuilder, endpoints) {
    final aliceId = const Uuid().v4();
    final bobId = const Uuid().v4();
    final alice = sessionBuilder.copyWith(authentication: AuthenticationOverride.authenticationInfo(aliceId, {}));
    final bob = sessionBuilder.copyWith(authentication: AuthenticationOverride.authenticationInfo(bobId, {}));

    /// Organisasi milik Alice dengan satu acara, 5 peserta (2 berhak grand prize), dan 2 hadiah.
    Future<({int orgId, int eventId, EventPrize doorprize, EventPrize grandprize})> seed() async {
      final org = await endpoints.organization.create(alice, 'PT Maju Bersama');
      final orgId = org.organization.id!;
      final event = await endpoints.event.create(alice, orgId, 'HUT 2026', null, false);
      await endpoints.participant.importRows(alice, event.id!, [
        row('001', 'Andi', groups: ['Doorprize', 'Grandprize']),
        row('002', 'Budi', groups: ['Doorprize', 'Grandprize'], points: 3),
        row('003', 'Citra'),
        row('004', 'Dewi'),
        row('005', 'Eko'),
      ], false);
      final doorprize = await endpoints.prize.save(
        alice,
        EventPrize(
          eventId: event.id!,
          name: 'Voucher',
          kind: PrizeKind.doorprize,
          quantity: 3,
          sortOrder: 1,
          eligibleGroups: ['Doorprize'],
          openToAll: false,
        ),
      );
      final grandprize = await endpoints.prize.save(
        alice,
        EventPrize(
          eventId: event.id!,
          name: 'Motor',
          kind: PrizeKind.grandprize,
          quantity: 1,
          sortOrder: 2,
          eligibleGroups: ['Grandprize'],
          openToAll: false,
        ),
      );
      return (orgId: orgId, eventId: event.id!, doorprize: doorprize, grandprize: grandprize);
    }

    group('akses', () {
      test('tanpa login ditolak', () async {
        await expectLater(
          () => endpoints.organization.mine(sessionBuilder),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test('pengguna organisasi lain tidak bisa membaca, mengubah, atau mengundi', () async {
        final s = await seed();
        expect(await endpoints.organization.mine(bob), isEmpty);
        await expectLater(() => endpoints.event.list(bob, s.orgId), throwsA(isA<UndianException>()));
        await expectLater(() => endpoints.participant.list(bob, s.eventId), throwsA(isA<UndianException>()));
        await expectLater(
          () => endpoints.participant.importRows(bob, s.eventId, [row('999', 'Penyusup')], false),
          throwsA(isA<UndianException>()),
        );
        await expectLater(() => endpoints.draw.draw(bob, s.grandprize.id!, 1), throwsA(isA<UndianException>()));
        await expectLater(
          () => endpoints.prize.save(bob, s.doorprize.copyWith(quantity: 99)),
          throwsA(isA<UndianException>()),
        );
      });

      test('viewer boleh melihat tapi tidak boleh mengundi', () async {
        final s = await seed();
        await Membership.db.insertRow(
          sessionBuilder.build(),
          Membership(
            organizationId: s.orgId,
            authUserId: UuidValue.withValidation(bobId),
            role: MemberRole.viewer,
            createdAt: DateTime.now().toUtc(),
          ),
        );
        expect(await endpoints.participant.list(bob, s.eventId), hasLength(5));
        await expectLater(() => endpoints.draw.draw(bob, s.doorprize.id!, 1), throwsA(isA<UndianException>()));
      });
    });

    group('import peserta', () {
      test('menolak NIK ganda, nama kosong, dan poin < 1; NIK lama diperbarui', () async {
        final s = await seed();
        final result = await endpoints.participant.importRows(alice, s.eventId, [
          row('001', 'Andi Pratama', groups: ['Doorprize', 'Grandprize']),
          row('006', 'Fajar'),
          row('006', 'Fajar Lagi'),
          row('007', '  '),
          row('008', 'Gita', points: 0),
        ], false);
        expect(result.inserted, 1);
        expect(result.updated, 1);
        expect(result.rejected, hasLength(3));
        final names = (await endpoints.participant.list(alice, s.eventId)).map((p) => p.name);
        expect(names, containsAll(['Andi Pratama', 'Fajar']));
        expect(names, hasLength(6));
      });

      test('ganti semua menghapus peserta yang tidak ada di file, tapi ditolak setelah ada pemenang', () async {
        final s = await seed();
        await endpoints.participant.importRows(alice, s.eventId, [row('001', 'Andi'), row('002', 'Budi')], true);
        expect(await endpoints.participant.list(alice, s.eventId), hasLength(2));

        await endpoints.draw.draw(alice, s.doorprize.id!, 1);
        await expectLater(
          () => endpoints.participant.importRows(alice, s.eventId, [row('001', 'Andi')], true),
          throwsA(isA<UndianException>()),
        );
      });
    });

    group('undian', () {
      test('hanya peserta berhak yang terpilih, stok dan nomor putaran dijaga', () async {
        final s = await seed();
        final first = await endpoints.draw.draw(alice, s.grandprize.id!, 1);
        expect(first.roundNo, 1);
        expect(first.poolSize, 2);
        expect(first.winners.single.groups, contains('Grandprize'));
        expect(first.winnerRecords.single.participantId, first.winners.single.id);

        await expectLater(() => endpoints.draw.draw(alice, s.grandprize.id!, 1), throwsA(isA<UndianException>()));

        final second = await endpoints.draw.draw(alice, s.doorprize.id!, 3);
        expect(second.roundNo, 2);
        expect(second.poolSize, 4, reason: 'pemenang grand prize tidak ikut lagi');
        expect(second.winners.map((p) => p.id), isNot(contains(first.winners.single.id)));
        expect(await endpoints.draw.winners(alice, s.eventId), hasLength(4));
      });

      test('hangus wajib beralasan, mengembalikan stok, dan orangnya tidak diundi lagi', () async {
        final s = await seed();
        final first = await endpoints.draw.draw(alice, s.grandprize.id!, 1);
        final record = first.winnerRecords.single;

        await expectLater(
          () => endpoints.draw.setStatus(alice, record.id!, WinnerStatus.hangus, ''),
          throwsA(isA<UndianException>()),
        );
        await endpoints.draw.setStatus(alice, record.id!, WinnerStatus.hangus, 'Tidak hadir');

        final redraw = await endpoints.draw.draw(alice, s.grandprize.id!, 1);
        expect(redraw.winners.single.id, isNot(first.winners.single.id));
        await expectLater(
          () => endpoints.draw.setStatus(alice, record.id!, WinnerStatus.sah, null),
          throwsA(isA<UndianException>()),
        );
      });

      test('setiap undian tercatat di log audit', () async {
        final s = await seed();
        await endpoints.draw.draw(alice, s.doorprize.id!, 2);
        final logs = await AuditLog.db.find(
          sessionBuilder.build(),
          where: (t) => t.organizationId.equals(s.orgId) & t.action.equals('draw'),
        );
        expect(logs.single.detail, startsWith('Putaran 1, Voucher'));
        expect(logs.single.authUserId, UuidValue.withValidation(aliceId));
      });

      test('jumlah unit hadiah tidak bisa dikurangi di bawah yang sudah terundi', () async {
        final s = await seed();
        await endpoints.draw.draw(alice, s.doorprize.id!, 2);
        await expectLater(
          () => endpoints.prize.save(alice, s.doorprize.copyWith(quantity: 1)),
          throwsA(isA<UndianException>()),
        );
      });
    });
  });
}
