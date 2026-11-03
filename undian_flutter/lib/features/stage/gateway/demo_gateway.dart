import 'package:undian_core/undian_core.dart';

import '../demo_data.dart';
import 'stage_gateway.dart';

/// Mode demo: data contoh dan undian lokal, tanpa server. Untuk presentasi dan latihan.
class DemoStageGateway implements StageGateway {
  DemoStageGateway({DrawEngine? engine}) : _engine = engine ?? DrawEngine();

  final DrawEngine _engine;

  @override
  bool get isDemo => true;

  @override
  Future<StageData> load() async =>
      StageData(participants: DemoData.participants(), prizes: DemoData.prizes(), winners: const []);

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
  Future<void> forfeit(Winner winner, String reason) async {}
}
