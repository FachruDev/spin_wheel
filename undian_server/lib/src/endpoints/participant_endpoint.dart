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

  /// Menambah satu peserta lewat formulir. NIK harus belum terdaftar di acara ini.
  Future<EventParticipant> add(Session session, int eventId, ParticipantInput input) async {
    final row = _toImportRow(input).cleaned();
    ensureValid(core.UndianRules.participantProblem(row));
    return session.db.transaction((tx) async {
      final event = await requireEvent(session, eventId, roles: adminRole, transaction: tx);
      await _ensureNikFree(session, eventId, row.nik, tx);
      final saved = await EventParticipant.db.insertRow(session, _fromRow(eventId, row), transaction: tx);
      await audit(
        session,
        organizationId: event.organizationId,
        eventId: eventId,
        action: 'participant.add',
        detail: 'Menambah peserta ${row.nik} (${row.name})',
        transaction: tx,
      );
      return saved;
    });
  }

  /// Mengubah data satu peserta. NIK boleh diganti selama belum dipakai peserta lain.
  Future<EventParticipant> update(Session session, int participantId, ParticipantInput input) async {
    final row = _toImportRow(input).cleaned();
    ensureValid(core.UndianRules.participantProblem(row));
    return session.db.transaction((tx) async {
      final existing = await EventParticipant.db.findById(session, participantId, transaction: tx);
      if (existing == null) throw notFound();
      final event = await requireEvent(session, existing.eventId, roles: adminRole, transaction: tx);
      if (row.nik != existing.nik) await _ensureNikFree(session, existing.eventId, row.nik, tx);
      final saved = await EventParticipant.db.updateRow(
        session,
        _fromRow(existing.eventId, row).copyWith(id: participantId),
        transaction: tx,
      );
      await audit(
        session,
        organizationId: event.organizationId,
        eventId: event.id,
        action: 'participant.update',
        detail: 'Mengubah peserta ${existing.nik} (${row.name})',
        transaction: tx,
      );
      return saved;
    });
  }

  /// Menghapus peserta yang belum pernah terundi.
  Future<void> delete(Session session, int participantId) async {
    await session.db.transaction((tx) async {
      final participant = await EventParticipant.db.findById(session, participantId, transaction: tx);
      if (participant == null) throw notFound();
      final event = await requireEvent(session, participant.eventId, roles: adminRole, transaction: tx);
      final drawn = await PrizeWinner.db.count(
        session,
        where: (t) => t.participantId.equals(participantId),
        transaction: tx,
      );
      if (drawn > 0) throw UndianException(message: core.UndianRules.deleteDrawnParticipantMessage);
      await EventParticipant.db.deleteRow(session, participant, transaction: tx);
      await audit(
        session,
        organizationId: event.organizationId,
        eventId: event.id,
        action: 'participant.delete',
        detail: 'Menghapus peserta ${participant.nik} (${participant.name})',
        transaction: tx,
      );
    });
  }

  static Future<void> _ensureNikFree(Session session, int eventId, String nik, Transaction tx) async {
    final taken = await EventParticipant.db.count(
      session,
      where: (t) => t.eventId.equals(eventId) & t.nik.equals(nik),
      transaction: tx,
    );
    if (taken > 0) throw UndianException(message: core.UndianRules.duplicateNikMessage(nik));
  }

  static EventParticipant _fromRow(int eventId, core.ImportRow row) => EventParticipant(
    eventId: eventId,
    nik: row.nik,
    name: row.name,
    area: row.area,
    department: row.department,
    employmentStatus: row.employmentStatus,
    phone: row.phone,
    points: row.points,
    groups: row.groups,
  );

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
