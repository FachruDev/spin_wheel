import 'dart:math';

import 'package:test/test.dart';
import 'package:undian_core/undian_core.dart';

Participant person(int id, {Set<String> groups = const {'A'}, int points = 1}) =>
    Participant(id: id, nik: '$id'.padLeft(8, '0'), name: 'Peserta $id', groups: groups, points: points);

void main() {
  const doorprizeA = Prize(id: 1, name: 'Voucher', kind: PrizeKind.doorprize, quantity: 3, eligibleGroups: {'A'});

  group('eligible', () {
    test('mencocokkan grup secara persis, bukan sebagian teks', () {
      final people = [
        person(1, groups: {'Grandprize Bogor'}),
        person(2, groups: {'Grandprize Bogor Plus'}),
        person(3, groups: {}),
      ];
      const prize = Prize(
        id: 9,
        name: 'Motor',
        kind: PrizeKind.grandprize,
        quantity: 1,
        eligibleGroups: {'Grandprize Bogor'},
      );
      final ids = DrawEngine.eligible(participants: people, prize: prize).map((p) => p.id);
      expect(ids, [1]);
    });

    test('daftar grup kosong berarti tidak ada yang berhak', () {
      const prize = Prize(id: 9, name: 'X', kind: PrizeKind.doorprize, quantity: 1);
      expect(DrawEngine.eligible(participants: [person(1)], prize: prize), isEmpty);
    });

    test('openToAll mengikutkan semua peserta', () {
      const prize = Prize(id: 9, name: 'X', kind: PrizeKind.grandprize, quantity: 1, openToAll: true);
      final people = [
        person(1, groups: {}),
        person(2, groups: {'B'}),
      ];
      expect(DrawEngine.eligible(participants: people, prize: prize), hasLength(2));
    });

    test('pemenang hadiah lain tidak ikut lagi kecuali boleh menang berkali-kali', () {
      final people = [person(1), person(2)];
      const winners = [Winner(participantId: 1, prizeId: 77)];
      expect(DrawEngine.eligible(participants: people, prize: doorprizeA, winners: winners).map((p) => p.id), [2]);
      expect(
        DrawEngine.eligible(
          participants: people,
          prize: doorprizeA,
          winners: winners,
          allowMultipleWins: true,
        ).map((p) => p.id),
        [1, 2],
      );
    });

    test('peserta hangus tidak diikutkan lagi walau boleh menang berkali-kali', () {
      final people = [person(1), person(2)];
      const winners = [Winner(participantId: 1, prizeId: 77, status: WinnerStatus.hangus)];
      expect(
        DrawEngine.eligible(
          participants: people,
          prize: doorprizeA,
          winners: winners,
          allowMultipleWins: true,
        ).map((p) => p.id),
        [2],
      );
    });
  });

  group('remainingStock', () {
    test('pemenang hangus mengembalikan unit ke stok', () {
      const winners = [
        Winner(participantId: 1, prizeId: 1),
        Winner(participantId: 2, prizeId: 1, status: WinnerStatus.hangus),
        Winner(participantId: 3, prizeId: 2),
      ];
      expect(DrawEngine.remainingStock(doorprizeA, winners), 2);
    });
  });

  group('draw', () {
    test('tidak pernah memilih orang yang sama dua kali', () {
      final engine = DrawEngine(random: Random(1));
      final pool = [for (var i = 0; i < 50; i++) person(i, points: 1 + i % 4)];
      for (var round = 0; round < 200; round++) {
        final ids = engine.draw(pool, 20).map((p) => p.id).toList();
        expect(ids.toSet(), hasLength(20));
      }
    });

    test('peluang sebanding poin: poin 3 menang sekitar 75% melawan poin 1', () {
      final engine = DrawEngine(random: Random(42));
      final pool = [person(1, points: 3), person(2, points: 1)];
      var wins = 0;
      const trials = 20000;
      for (var i = 0; i < trials; i++) {
        if (engine.draw(pool, 1).single.id == 1) wins++;
      }
      expect(wins / trials, closeTo(0.75, 0.015));
    });

    test('pemenang kedua mengikuti sisa tiket setelah pemenang pertama keluar', () {
      // Poin 2,1,1 → P(peserta 2 menjadi pemenang kedua | peserta 1 pertama) = 1/2.
      final engine = DrawEngine(random: Random(7));
      final pool = [person(1, points: 2), person(2), person(3)];
      var firstIsOne = 0, secondIsTwo = 0;
      for (var i = 0; i < 30000; i++) {
        final r = engine.draw(pool, 2);
        if (r[0].id == 1) {
          firstIsOne++;
          if (r[1].id == 2) secondIsTwo++;
        }
      }
      expect(firstIsOne / 30000, closeTo(0.5, 0.015));
      expect(secondIsTwo / firstIsOne, closeTo(0.5, 0.02));
    });

    test('menolak poin di bawah 1', () {
      expect(() => DrawEngine().draw([person(1, points: 0)], 1), throwsArgumentError);
    });
  });

  group('drawForPrize', () {
    test('menolak jumlah melebihi stok', () {
      expect(
        () => DrawEngine().drawForPrize(
          participants: [for (var i = 0; i < 10; i++) person(i)],
          prize: doorprizeA,
          winners: const [],
          count: 4,
        ),
        throwsA(isA<DrawException>()),
      );
    });

    test('menolak jika peserta berhak kurang dari jumlah pemenang', () {
      expect(
        () => DrawEngine().drawForPrize(
          participants: [person(1), person(2)],
          prize: doorprizeA,
          winners: const [],
          count: 3,
        ),
        throwsA(isA<DrawException>()),
      );
    });

    test('hanya memilih dari peserta yang berhak', () {
      final people = [
        person(1),
        person(2, groups: {'B'}),
        person(3),
      ];
      final result = DrawEngine().drawForPrize(participants: people, prize: doorprizeA, winners: const [], count: 2);
      expect(result.map((p) => p.id).toSet(), {1, 3});
    });
  });
}
