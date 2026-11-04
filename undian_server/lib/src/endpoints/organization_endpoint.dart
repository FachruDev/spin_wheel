import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:undian_core/undian_core.dart' as core;

import '../access.dart';
import '../generated/protocol.dart';

/// Organisasi (tenant) milik pengguna: membuat, melihat, dan mengatur identitasnya.
class OrganizationEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Membuat organisasi baru; pembuatnya otomatis menjadi admin.
  Future<MyOrganization> create(Session session, String name) async {
    final userId = currentUserId(session);
    final trimmed = name.trim();
    ensureValid(core.UndianRules.nameProblem(trimmed, 'organisasi'));
    return session.db.transaction((tx) async {
      final now = DateTime.now().toUtc();
      final organization = await Organization.db.insertRow(
        session,
        Organization(
          name: trimmed,
          primaryColor: core.UndianRules.defaultPrimaryColor,
          accentColor: core.UndianRules.defaultAccentColor,
          createdAt: now,
        ),
        transaction: tx,
      );
      await Membership.db.insertRow(
        session,
        Membership(organizationId: organization.id!, authUserId: userId, role: MemberRole.admin, createdAt: now),
        transaction: tx,
      );
      await audit(
        session,
        organizationId: organization.id!,
        action: 'organization.create',
        detail: 'Membuat organisasi "$trimmed"',
        transaction: tx,
      );
      return MyOrganization(organization: organization, role: MemberRole.admin);
    });
  }

  /// Semua organisasi tempat pengguna menjadi anggota.
  Future<List<MyOrganization>> mine(Session session) async {
    final userId = currentUserId(session);
    final memberships = await Membership.db.find(session, where: (t) => t.authUserId.equals(userId));
    if (memberships.isEmpty) return [];
    final roleByOrganization = {for (final m in memberships) m.organizationId: m.role};
    final organizations = await Organization.db.find(
      session,
      where: (t) => t.id.inSet(roleByOrganization.keys.toSet()),
      orderBy: (t) => t.name,
    );
    return [for (final o in organizations) MyOrganization(organization: o, role: roleByOrganization[o.id]!)];
  }

  /// Mengubah nama, warna, dan logo organisasi. Hanya admin.
  Future<Organization> updateBranding(
    Session session,
    int organizationId,
    String name,
    int primaryColor,
    int accentColor,
    ByteData? logo,
  ) async {
    await requireMembership(session, organizationId, roles: adminRole);
    final trimmed = name.trim();
    ensureValid(core.UndianRules.nameProblem(trimmed, 'organisasi'));
    ensureValid(core.UndianRules.logoProblem(logo?.lengthInBytes));
    final organization = await Organization.db.findById(session, organizationId);
    if (organization == null) throw notFound();
    final updated = await Organization.db.updateRow(
      session,
      organization.copyWith(name: trimmed, primaryColor: primaryColor, accentColor: accentColor, logo: logo),
    );
    await audit(session, organizationId: organizationId, action: 'organization.branding', detail: 'Mengubah identitas');
    return updated;
  }
}
