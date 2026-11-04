import 'package:serverpod/serverpod.dart';
import 'package:undian_core/undian_core.dart' as core;

import '../access.dart';
import '../generated/protocol.dart';

/// Pengundian. Hasil selalu ditentukan di server dan dicatat sebelum dikirim ke layar.
class DrawEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Mengundi [count] pemenang untuk [prizeId].
  ///
  /// Baris acara dikunci selama transaksi, jadi undian dalam satu acara berjalan bergantian
  /// dan satu orang tidak bisa memenangkan dua hadiah yang diundi bersamaan.
  Future<DrawResult> draw(Session session, int prizeId, int count) async {
    final userId = currentUserId(session);
    ensureValid(core.UndianRules.drawCountProblem(count));
    return session.db.transaction((tx) async {
      final prize = await EventPrize.db.findById(session, prizeId, transaction: tx);
      if (prize == null) throw notFound();
      final event = await requireEvent(
        session,
        prize.eventId,
        roles: drawRoles,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final participants = await EventParticipant.db.find(
        session,
        where: (t) => t.eventId.equals(event.id!),
        transaction: tx,
      );
      final winners = await PrizeWinner.db.find(session, where: (t) => t.eventId.equals(event.id!), transaction: tx);

      final coreParticipants = [for (final p in participants) _toCore(p)];
      final corePrize = _prizeToCore(prize);
      final coreWinners = [for (final w in winners) _winnerToCore(w)];
      final pool = core.DrawEngine.eligible(
        participants: coreParticipants,
        prize: corePrize,
        winners: coreWinners,
        allowMultipleWins: event.allowMultipleWins,
      );
      final List<core.Participant> drawn;
      try {
        drawn = core.DrawEngine().drawForPrize(
          participants: coreParticipants,
          prize: corePrize,
          winners: coreWinners,
          count: count,
          allowMultipleWins: event.allowMultipleWins,
        );
      } on core.DrawException catch (e) {
        throw UndianException(message: e.message);
      }

      final roundNo = core.UndianRules.nextRoundNo(winners.map((w) => w.roundNo));
      final now = DateTime.now().toUtc();
      final inserted = await PrizeWinner.db.insert(
        session,
        [
          for (final p in drawn)
            PrizeWinner(
              eventId: event.id!,
              prizeId: prizeId,
              participantId: p.id,
              roundNo: roundNo,
              status: WinnerStatus.sah,
              drawnAt: now,
              drawnBy: userId,
            ),
        ],
        transaction: tx,
      );
      final recordByParticipant = {for (final r in inserted) r.participantId: r};
      final byId = {for (final p in participants) p.id!: p};

      await audit(
        session,
        organizationId: event.organizationId,
        eventId: event.id,
        action: 'draw',
        detail:
            'Putaran $roundNo, ${prize.name}: ${drawn.map((p) => p.nik).join(', ')} '
            '(dari ${pool.length} peserta berhak)',
        transaction: tx,
      );

      final sample = (List.of(pool)..shuffle()).take(core.UndianRules.poolSampleSize);
      return DrawResult(
        roundNo: roundNo,
        prize: prize,
        winners: [for (final p in drawn) byId[p.id]!],
        winnerRecords: [for (final p in drawn) recordByParticipant[p.id]!],
        poolSize: pool.length,
        poolSample: [for (final p in sample) byId[p.id]!],
      );
    });
  }

  /// Mengubah status pemenang. Hangus wajib beralasan dan bersifat final, karena unitnya
  /// kembali ke stok dan bisa langsung diundi ulang.
  Future<PrizeWinner> setStatus(Session session, int winnerId, WinnerStatus status, String? note) async {
    final reason = note?.trim();
    return session.db.transaction((tx) async {
      final winner = await PrizeWinner.db.findById(session, winnerId, transaction: tx);
      if (winner == null) throw notFound();
      final event = await requireEvent(
        session,
        winner.eventId,
        roles: drawRoles,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      ensureValid(
        core.UndianRules.statusChangeProblem(
          current: core.WinnerStatus.values.byName(winner.status.name),
          next: core.WinnerStatus.values.byName(status.name),
          note: reason,
        ),
      );
      final updated = await PrizeWinner.db.updateRow(
        session,
        winner.copyWith(status: status, note: reason),
        transaction: tx,
      );
      await audit(
        session,
        organizationId: event.organizationId,
        eventId: event.id,
        action: 'winner.status',
        detail: 'Pemenang #$winnerId: ${winner.status.name} → ${status.name}${reason == null ? '' : ' ($reason)'}',
        transaction: tx,
      );
      return updated;
    });
  }

  Future<List<PrizeWinner>> winners(Session session, int eventId) async {
    await requireEvent(session, eventId);
    return PrizeWinner.db.find(
      session,
      where: (t) => t.eventId.equals(eventId),
      orderByList: (t) => [Order(column: t.roundNo), Order(column: t.id)],
    );
  }

  static core.Participant _toCore(EventParticipant p) => core.Participant(
    id: p.id!,
    nik: p.nik,
    name: p.name,
    area: p.area,
    department: p.department,
    employmentStatus: p.employmentStatus,
    groups: p.groups.toSet(),
    points: p.points,
  );

  static core.Prize _prizeToCore(EventPrize p) => core.Prize(
    id: p.id!,
    name: p.name,
    kind: core.PrizeKind.values.byName(p.kind.name),
    quantity: p.quantity,
    eligibleGroups: p.eligibleGroups.toSet(),
    openToAll: p.openToAll,
  );

  static core.Winner _winnerToCore(PrizeWinner w) => core.Winner(
    participantId: w.participantId,
    prizeId: w.prizeId,
    status: core.WinnerStatus.values.byName(w.status.name),
  );
}
