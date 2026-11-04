import 'package:serverpod/serverpod.dart';
import 'package:undian_core/undian_core.dart' as core;

import '../access.dart';
import '../generated/protocol.dart';

/// Peserta acara. File Excel dibaca di aplikasi; server menerima baris yang sudah dipetakan.
class ParticipantEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<EventParticipant>> list(Session session, int eventId) async {
    await requireEvent(session, eventId);
    return EventParticipant.db.find(session, where: (t) => t.eventId.equals(eventId), orderBy: (t) => t.name);
  }

  /// Menyimpan baris peserta: NIK yang sudah ada diperbarui, yang baru ditambahkan.
  ///
  /// Dengan [replaceAll], peserta yang tidak ada di file dihapus. Ini ditolak jika acara
  /// sudah punya pemenang, supaya riwayat undian tidak hilang.
  Future<ImportResult> importRows(
    Session session,
    int eventId,
    List<ParticipantInput> rows,
    bool replaceAll,
  ) async {
    final event = await requireEvent(session, eventId, roles: adminRole);

    final plan = core.UndianRules.planImport([for (final r in rows) _toImportRow(r)]);
    final valid = plan.valid;
    final rejected = plan.rejected;

    return session.db.transaction((tx) async {
      final existing = await EventParticipant.db.find(
        session,
        where: (t) => t.eventId.equals(eventId),
        transaction: tx,
      );
      final byNik = {for (final p in existing) p.nik: p};

      if (replaceAll) {
        final winnerCount = await PrizeWinner.db.count(
          session,
          where: (t) => t.eventId.equals(eventId),
          transaction: tx,
        );
        if (winnerCount > 0) throw UndianException(message: core.UndianRules.replaceAllWithWinnersMessage);
        final removed = {
          for (final p in existing)
            if (!valid.containsKey(p.nik)) p.id!,
        };
        if (removed.isNotEmpty) {
          await EventParticipant.db.deleteWhere(session, where: (t) => t.id.inSet(removed), transaction: tx);
        }
      }

      final toInsert = <EventParticipant>[];
      final toUpdate = <EventParticipant>[];
      for (final MapEntry(key: nik, value: row) in valid.entries) {
        final old = byNik[nik];
        final participant =
            (old ??
                    EventParticipant(
                      eventId: eventId,
                      nik: nik,
                      name: '',
                      area: '',
                      department: '',
                      employmentStatus: '',
                      points: 1,
                      groups: [],
                    ))
                .copyWith(
                  name: row.name,
                  area: row.area,
                  department: row.department,
                  employmentStatus: row.employmentStatus,
                  phone: row.phone,
                  points: row.points,
                  groups: row.groups,
                );
        (old == null ? toInsert : toUpdate).add(participant);
      }
      if (toInsert.isNotEmpty) await EventParticipant.db.insert(session, toInsert, transaction: tx);
      if (toUpdate.isNotEmpty) await EventParticipant.db.update(session, toUpdate, transaction: tx);

      await audit(
        session,
        organizationId: event.organizationId,
        eventId: eventId,
        action: 'participant.import',
        detail:
            '${toInsert.length} baru, ${toUpdate.length} diperbarui, ${rejected.length} ditolak'
            '${replaceAll ? ', mode ganti semua' : ''}',
        transaction: tx,
      );
      return ImportResult(inserted: toInsert.length, updated: toUpdate.length, rejected: rejected);
    });
  }

  static core.ImportRow _toImportRow(ParticipantInput r) => core.ImportRow(
    nik: r.nik,
    name: r.name,
    area: r.area,
    department: r.department,
    employmentStatus: r.employmentStatus,
    phone: r.phone,
    points: r.points,
    groups: r.groups,
  );
}
