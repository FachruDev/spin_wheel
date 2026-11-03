import 'package:serverpod/serverpod.dart';

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

    final rejected = <String>[];
    final valid = <String, ParticipantInput>{};
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final line = 'Baris ${i + 1}';
      final nik = row.nik.trim();
      if (nik.isEmpty) {
        rejected.add('$line: NIK kosong');
      } else if (row.name.trim().isEmpty) {
        rejected.add('$line ($nik): nama kosong');
      } else if (row.points < 1) {
        rejected.add('$line ($nik): poin harus minimal 1');
      } else if (valid.containsKey(nik)) {
        rejected.add('$line: NIK $nik muncul lebih dari sekali');
      } else {
        valid[nik] = row;
      }
    }

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
        if (winnerCount > 0) {
          throw UndianException(
            message:
                'Acara ini sudah punya pemenang, jadi data peserta tidak bisa diganti total. '
                'Gunakan mode tambah/perbarui.',
          );
        }
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
        final groups = {
          for (final g in row.groups)
            if (g.trim().isNotEmpty) g.trim(),
        }.toList()..sort();
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
                  name: row.name.trim(),
                  area: row.area.trim(),
                  department: row.department.trim(),
                  employmentStatus: row.employmentStatus.trim(),
                  phone: row.phone?.trim(),
                  points: row.points,
                  groups: groups,
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
}
