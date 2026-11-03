import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undian_flutter/features/stage/stage_controller.dart';
import 'package:undian_core/undian_core.dart';

void main() {
  late ProviderContainer container;
  StageState read() => container.read(stageControllerProvider);
  StageController controller() => container.read(stageControllerProvider.notifier);

  setUp(() {
    container = ProviderContainer(overrides: [drawEngineProvider.overrideWithValue(DrawEngine(random: Random(1)))]);
  });
  tearDown(() => container.dispose());

  test('doorprize: 10 pemenang per putaran, stok berkurang, pemenang tersembunyi sampai animasi selesai', () {
    final voucher = read().prizes.first;
    expect(read().mode, RevealMode.kartu);
    expect(read().perRound, 10);

    controller().primaryAction();
    final show = read().phase as StageShow;
    expect(show.winners, hasLength(10));
    expect(show.winners.every((p) => p.groups.intersection(voucher.eligibleGroups).isNotEmpty), isTrue);
    expect(read().remaining(voucher), voucher.quantity - 10);
    expect(read().isAnimating, isTrue);

    controller().primaryAction(); // Spasi saat animasi berjalan diabaikan.
    expect(read().winners, hasLength(10));

    controller().finishReveal(show.runId);
    expect(read().isAnimating, isFalse);
    controller().primaryAction();
    expect(read().phase, isA<StageIdle>());
  });

  test('grand prize memakai mode satu pemenang dan menolak saat stok habis', () {
    final motor = read().prizes.firstWhere((p) => p.name.contains('Motor'));
    controller().selectPrize(motor.id);
    expect(read().mode, RevealMode.panggung);
    expect(read().perRound, 1);

    controller().primaryAction();
    final show = read().phase as StageShow;
    expect(show.winners.single.employmentStatus, isNot('Kontrak'));
    controller().finishReveal(show.runId);
    controller().primaryAction();

    controller().primaryAction();
    expect(read().phase, isA<StageIdle>());
    expect(read().message, contains('Stok'));
  });

  test('pemenang hangus mengembalikan stok dan tidak diundi lagi', () {
    final motor = read().prizes.firstWhere((p) => p.name.contains('Motor'));
    controller().selectPrize(motor.id);
    controller().primaryAction();
    final show = read().phase as StageShow;
    final absent = show.winners.single;
    controller().finishReveal(show.runId);

    controller().forfeit(read().winners.single);
    expect(read().remaining(motor), 1);
    expect(read().eligibleFor(motor).any((p) => p.id == absent.id), isFalse);
  });

  test('kartu dibatasi maksimal 20 per putaran', () {
    controller().changePerRound(100);
    expect(read().perRound, 20);
    controller().changePerRound(-100);
    expect(read().perRound, 1);
  });
}
