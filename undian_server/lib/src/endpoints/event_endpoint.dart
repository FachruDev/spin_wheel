import 'package:serverpod/serverpod.dart';
import 'package:undian_core/undian_core.dart' as core;

import '../access.dart';
import '../generated/protocol.dart';

/// Acara undian dalam sebuah organisasi.
class EventEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  Future<DrawEvent> create(
    Session session,
    int organizationId,
    String name,
    DateTime? eventDate,
    bool allowMultipleWins,
  ) async {
    await requireMembership(session, organizationId, roles: adminRole);
    final trimmed = name.trim();
    ensureValid(core.UndianRules.nameProblem(trimmed, 'acara'));
    final event = await DrawEvent.db.insertRow(
      session,
      DrawEvent(
        organizationId: organizationId,
        name: trimmed,
        eventDate: eventDate,
        allowMultipleWins: allowMultipleWins,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    await audit(
      session,
      organizationId: organizationId,
      eventId: event.id,
      action: 'event.create',
      detail: 'Membuat acara "$trimmed"',
    );
    return event;
  }

  /// Mengubah nama, tanggal, dan aturan menang lebih dari sekali. Aturan baru berlaku untuk
  /// undian berikutnya; pemenang yang sudah ada tidak berubah.
  Future<DrawEvent> update(
    Session session,
    int eventId,
    String name,
    DateTime? eventDate,
    bool allowMultipleWins,
  ) async {
    final trimmed = name.trim();
    ensureValid(core.UndianRules.nameProblem(trimmed, 'acara'));
    return session.db.transaction((tx) async {
      final event = await requireEvent(
        session,
        eventId,
        roles: adminRole,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final updated = await DrawEvent.db.updateRow(
        session,
        event.copyWith(name: trimmed, eventDate: eventDate, allowMultipleWins: allowMultipleWins),
        transaction: tx,
      );
      await audit(
        session,
        organizationId: event.organizationId,
        eventId: eventId,
        action: 'event.update',
        detail: 'Mengubah acara "${event.name}" menjadi "$trimmed"',
        transaction: tx,
      );
      return updated;
    });
  }

  Future<List<DrawEvent>> list(Session session, int organizationId) async {
    await requireMembership(session, organizationId);
    return DrawEvent.db.find(
      session,
      where: (t) => t.organizationId.equals(organizationId),
      orderBy: (t) => t.createdAt,
      orderDescending: true,
    );
  }
}
