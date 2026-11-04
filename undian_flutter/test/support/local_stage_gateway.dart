import 'package:undian_core/undian_core.dart';
import 'package:undian_flutter/features/stage/gateway/stage_gateway.dart';

import '../../tool/sample_data.dart';

/// Panggung untuk tes: data contoh dan undian lokal, tanpa server.
class LocalStageGateway implements StageGateway {
  LocalStageGateway({DrawEngine? engine}) : _engine = engine ?? DrawEngine();

  final DrawEngine _engine;

  @override
  Future<StageData> load() async =>
      StageData(participants: SampleData.participants(), prizes: SampleData.prizes(), winners: const []);

  @override
  Future<DrawOutcome> draw({required Prize prize, required int count, required StageData current}) async {
    final pool = DrawEngine.eligible(
      participants: current.participants,
      prize: prize,
      winners: current.winners,
      allowMultipleWins: current.allowMultipleWins,
    );
    final drawn = _engine.drawForPrize(
      participants: current.participants,
      prize: prize,
      winners: current.winners,
      count: count,
      allowMultipleWins: current.allowMultipleWins,
    );
    return DrawOutcome(
      winners: drawn,
      records: [for (final p in drawn) Winner(participantId: p.id, prizeId: prize.id)],
      pool: pool,
    );
  }

  @override
  Future<void> cancelWinner(Winner winner, WinnerStatus status, String reason) async {}
}
