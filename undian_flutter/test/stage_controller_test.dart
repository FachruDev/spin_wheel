import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:undian_client/undian_client.dart' show UndianException;
import 'package:undian_core/undian_core.dart';
import 'package:undian_flutter/features/stage/gateway/demo_gateway.dart';
import 'package:undian_flutter/features/stage/gateway/stage_gateway.dart';
import 'package:undian_flutter/features/stage/stage_controller.dart';

/// Gateway yang menolak setiap undian, seperti server yang menjawab dengan UndianException.
class _RejectingGateway extends DemoStageGateway {
  @override
  bool get isDemo => false;

  @override
  Future<DrawOutcome> draw({required Prize prize, required int count, required StageData current}) =>
      Future.error(UndianException(message: 'Peran Anda tidak diizinkan melakukan aksi ini.'));
}

void main() {
  late ProviderContainer container;
  StageState read() => container.read(stageControllerProvider);
  StageController controller() => container.read(stageControllerProvider.notifier);

  Future<void> start(StageGateway gateway) async {
    container = ProviderContainer(overrides: [stageGatewayProvider.overrideWithValue(gateway)]);
    addTearDown(container.dispose);
    await controller().loaded;
  }

  test('doorprize: 10 pemenang per putaran, stok berkurang, Spasi diabaikan selama animasi', () async {
    await start(DemoStageGateway(engine: DrawEngine(random: Random(1))));
    final voucher = read().prizes.first;
    expect(read().mode, RevealMode.kartu);
    expect(read().perRound, 10);

    await controller().primaryAction();
    final show = read().phase as StageShow;
    expect(show.winners, hasLength(10));
    expect(show.winners.every((p) => p.groups.intersection(voucher.eligibleGroups).isNotEmpty), isTrue);
    expect(read().remaining(voucher), voucher.quantity - 10);
    expect(read().isAnimating, isTrue);

    await controller().primaryAction();
    expect(read().winners, hasLength(10));

    controller().finishReveal(show.runId);
    expect(read().isAnimating, isFalse);
    await controller().primaryAction();
    expect(read().phase, isA<StageIdle>());
  });

  test('grand prize memakai mode satu pemenang dan menolak saat stok habis', () async {
    await start(DemoStageGateway(engine: DrawEngine(random: Random(1))));
    final motor = read().prizes.firstWhere((p) => p.name.contains('Motor'));
    controller().selectPrize(motor.id);
    expect(read().mode, RevealMode.panggung);
    expect(read().perRound, 1);

    await controller().primaryAction();
    final show = read().phase as StageShow;
    expect(show.winners.single.employmentStatus, isNot('Kontrak'));
    controller().finishReveal(show.runId);
    await controller().primaryAction();

    await controller().primaryAction();
    expect(read().phase, isA<StageIdle>());
    expect(read().message, contains('Stok'));
  });

  test('pemenang hangus mengembalikan stok dan tidak diundi lagi', () async {
    await start(DemoStageGateway(engine: DrawEngine(random: Random(1))));
    final motor = read().prizes.firstWhere((p) => p.name.contains('Motor'));
    controller().selectPrize(motor.id);
    await controller().primaryAction();
    final show = read().phase as StageShow;
    final absent = show.winners.single;
    controller().finishReveal(show.runId);

    await controller().forfeit(read().winners.single, 'Tidak hadir');
    expect(read().remaining(motor), 1);
    expect(read().eligibleFor(motor).any((p) => p.id == absent.id), isFalse);
  });

  test('kartu dibatasi maksimal 20 per putaran', () async {
    await start(DemoStageGateway());
    controller().changePerRound(100);
    expect(read().perRound, 20);
    controller().changePerRound(-100);
    expect(read().perRound, 1);
  });

  test('pesan dari server ditampilkan ke operator dan panggung tetap siap', () async {
    await start(_RejectingGateway());
    await controller().primaryAction();
    expect(read().phase, isA<StageIdle>());
    expect(read().busy, isFalse);
    expect(read().message, 'Peran Anda tidak diizinkan melakukan aksi ini.');
    expect(read().winners, isEmpty);
  });
}
