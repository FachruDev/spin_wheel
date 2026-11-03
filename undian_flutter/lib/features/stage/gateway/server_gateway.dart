import 'package:undian_client/undian_client.dart' as api;
import 'package:undian_core/undian_core.dart';

import '../../../core/server/core_mapping.dart';
import 'stage_gateway.dart';

/// Panggung untuk acara di server: undian dijalankan dan dicatat oleh server.
class ServerStageGateway implements StageGateway {
  ServerStageGateway(this._client, this._event);

  final api.Client _client;
  final api.DrawEvent _event;

  /// id catatan pemenang di server, per (peserta, hadiah); dipakai saat menandai hangus.
  final _recordIds = <(int, int), int>{};

  @override
  bool get isDemo => false;

  int get _eventId => _event.id!;

  @override
  Future<StageData> load() async {
    final (participants, prizes, winners) = await (
      _client.participant.list(_eventId),
      _client.prize.list(_eventId),
      _client.draw.winners(_eventId),
    ).wait;
    _recordIds
      ..clear()
      ..addEntries(winners.map((w) => MapEntry((w.participantId, w.prizeId), w.id!)));
    return StageData(
      participants: [for (final p in participants) toCoreParticipant(p)],
      prizes: [for (final p in prizes) toCorePrize(p)],
      winners: [for (final w in winners) toCoreWinner(w)],
      allowMultipleWins: _event.allowMultipleWins,
    );
  }

  @override
  Future<DrawOutcome> draw({required Prize prize, required int count, required StageData current}) async {
    final result = await _client.draw.draw(prize.id, count);
    for (final record in result.winnerRecords) {
      _recordIds[(record.participantId, record.prizeId)] = record.id!;
    }
    return DrawOutcome(
      winners: [for (final p in result.winners) toCoreParticipant(p)],
      records: [for (final w in result.winnerRecords) toCoreWinner(w)],
      pool: [for (final p in result.poolSample) toCoreParticipant(p)],
    );
  }

  @override
  Future<void> forfeit(Winner winner, String reason) async {
    final id = _recordIds[(winner.participantId, winner.prizeId)];
    if (id == null) throw api.UndianException(message: 'Data pemenang tidak ditemukan. Muat ulang panggung.');
    await _client.draw.setStatus(id, api.WinnerStatus.hangus, reason);
  }
}
