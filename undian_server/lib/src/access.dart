import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import 'generated/protocol.dart';

/// Peran yang boleh membaca data organisasi.
const anyRole = {MemberRole.admin, MemberRole.drawOperator, MemberRole.viewer};

/// Peran yang boleh mengatur acara, peserta, dan hadiah.
const adminRole = {MemberRole.admin};

/// Peran yang boleh menjalankan undian dan mengubah status pemenang.
const drawRoles = {MemberRole.admin, MemberRole.drawOperator};

/// Pesan yang sama untuk "tidak ada" dan "bukan milik Anda", supaya keberadaan data
/// organisasi lain tidak bocor.
UndianException notFound() => UndianException(message: 'Data tidak ditemukan atau Anda tidak punya akses.');

UuidValue currentUserId(Session session) {
  final auth = session.authenticated;
  if (auth == null) throw UndianException(message: 'Silakan login terlebih dahulu.');
  return auth.authUserId;
}

/// Memastikan pengguna yang login adalah anggota [organizationId] dengan salah satu [roles].
Future<Membership> requireMembership(
  Session session,
  int organizationId, {
  Set<MemberRole> roles = anyRole,
  Transaction? transaction,
}) async {
  final userId = currentUserId(session);
  final membership = await Membership.db.findFirstRow(
    session,
    where: (t) => t.organizationId.equals(organizationId) & t.authUserId.equals(userId),
    transaction: transaction,
  );
  if (membership == null) throw notFound();
  if (!roles.contains(membership.role)) {
    throw UndianException(message: 'Peran Anda tidak diizinkan melakukan aksi ini.');
  }
  return membership;
}

/// Mengambil acara sekaligus memastikan pengguna berhak atas organisasinya.
Future<DrawEvent> requireEvent(
  Session session,
  int eventId, {
  Set<MemberRole> roles = anyRole,
  Transaction? transaction,
  LockMode? lockMode,
}) async {
  final event = await DrawEvent.db.findById(session, eventId, transaction: transaction, lockMode: lockMode);
  if (event == null) throw notFound();
  await requireMembership(session, event.organizationId, roles: roles, transaction: transaction);
  return event;
}

Future<void> audit(
  Session session, {
  required int organizationId,
  int? eventId,
  required String action,
  required String detail,
  Transaction? transaction,
}) async {
  await AuditLog.db.insertRow(
    session,
    AuditLog(
      organizationId: organizationId,
      eventId: eventId,
      authUserId: currentUserId(session),
      action: action,
      detail: detail,
      createdAt: DateTime.now().toUtc(),
    ),
    transaction: transaction,
  );
}
