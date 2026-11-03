import 'package:serverpod/serverpod.dart';

import '../access.dart';
import '../generated/protocol.dart';

/// Hadiah dalam sebuah acara.
class PrizeEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<List<EventPrize>> list(Session session, int eventId) async {
    await requireEvent(session, eventId);
    return EventPrize.db.find(session, where: (t) => t.eventId.equals(eventId), orderBy: (t) => t.sortOrder);
  }

  /// Menambah hadiah baru (id kosong) atau memperbarui yang sudah ada.
  Future<EventPrize> save(Session session, EventPrize prize) async {
    final name = prize.name.trim();
    if (name.isEmpty) throw UndianException(message: 'Nama hadiah wajib diisi.');
    if (prize.quantity < 1) throw UndianException(message: 'Jumlah unit minimal 1.');
    final groups = {
      for (final g in prize.eligibleGroups)
        if (g.trim().isNotEmpty) g.trim(),
    }.toList()..sort();
    if (!prize.openToAll && groups.isEmpty) {
      throw UndianException(message: 'Pilih minimal satu grup peserta, atau buka hadiah untuk semua peserta.');
    }

    return session.db.transaction((tx) async {
      final id = prize.id;
      final cleaned = prize.copyWith(name: name, eligibleGroups: groups);
      if (id == null) {
        final event = await requireEvent(session, prize.eventId, roles: adminRole, transaction: tx);
        final saved = await EventPrize.db.insertRow(session, cleaned, transaction: tx);
        await audit(
          session,
          organizationId: event.organizationId,
          eventId: event.id,
          action: 'prize.create',
          detail: 'Hadiah "$name" (${prize.quantity} unit)',
          transaction: tx,
        );
        return saved;
      }

      final existing = await EventPrize.db.findById(session, id, transaction: tx);
      if (existing == null || existing.eventId != prize.eventId) throw notFound();
      final event = await requireEvent(session, existing.eventId, roles: adminRole, transaction: tx);
      final used = await PrizeWinner.db.count(
        session,
        where: (t) => t.prizeId.equals(id) & t.status.notEquals(WinnerStatus.hangus),
        transaction: tx,
      );
      if (prize.quantity < used) {
        throw UndianException(message: 'Sudah $used unit terundi; jumlah unit tidak boleh kurang dari itu.');
      }
      final saved = await EventPrize.db.updateRow(session, cleaned, transaction: tx);
      await audit(
        session,
        organizationId: event.organizationId,
        eventId: event.id,
        action: 'prize.update',
        detail: 'Hadiah "$name" (${prize.quantity} unit)',
        transaction: tx,
      );
      return saved;
    });
  }

  /// Menghapus hadiah yang belum pernah diundi.
  Future<void> delete(Session session, int prizeId) async {
    final prize = await EventPrize.db.findById(session, prizeId);
    if (prize == null) throw notFound();
    final event = await requireEvent(session, prize.eventId, roles: adminRole);
    final drawn = await PrizeWinner.db.count(session, where: (t) => t.prizeId.equals(prizeId));
    if (drawn > 0) throw UndianException(message: 'Hadiah yang sudah diundi tidak bisa dihapus.');
    await EventPrize.db.deleteRow(session, prize);
    await audit(
      session,
      organizationId: event.organizationId,
      eventId: event.id,
      action: 'prize.delete',
      detail: 'Hadiah "${prize.name}"',
    );
  }
}
