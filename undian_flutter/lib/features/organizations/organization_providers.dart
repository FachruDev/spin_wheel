import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/server/server_providers.dart';
import '../branding/branding.dart';

/// Organisasi milik pengguna yang login, beserta perannya.
final myOrganizationsProvider = FutureProvider.autoDispose<List<MyOrganization>>(
  (ref) => ref.watch(clientProvider).organization.mine(),
);

/// Satu organisasi berdasarkan id, diambil dari [myOrganizationsProvider].
final organizationProvider = FutureProvider.autoDispose.family<MyOrganization, int>((ref, id) async {
  final all = await ref.watch(myOrganizationsProvider.future);
  return all.firstWhere(
    (m) => m.organization.id == id,
    orElse: () => throw UndianException(message: 'Organisasi tidak ditemukan atau Anda tidak punya akses.'),
  );
});

extension MyOrganizationRole on MyOrganization {
  bool get canManage => role == MemberRole.admin;
  bool get canDraw => role == MemberRole.admin || role == MemberRole.drawOperator;

  String get roleLabel => switch (role) {
    MemberRole.admin => 'Admin',
    MemberRole.drawOperator => 'Operator',
    MemberRole.viewer => 'Viewer',
  };
}

extension OrganizationBranding on Organization {
  /// Identitas organisasi untuk tampilan panggung.
  Branding toBranding({String? eventTitle}) {
    final logoData = logo;
    return Branding(
      organizationName: name,
      eventTitle: eventTitle ?? const Branding().eventTitle,
      palette: BrandPalette.fromColors(Color(primaryColor), Color(accentColor)),
      logoBytes: logoData?.buffer.asUint8List(logoData.offsetInBytes, logoData.lengthInBytes),
    );
  }
}

/// Menyimpan identitas organisasi ke server lalu memuat ulang daftar organisasi.
Future<void> saveOrganizationBranding(WidgetRef ref, int organizationId, Branding branding) async {
  final logo = branding.logoBytes;
  await ref
      .read(clientProvider)
      .organization
      .updateBranding(
        organizationId,
        branding.organizationName,
        branding.primary.toARGB32(),
        branding.accent.toARGB32(),
        logo == null ? null : ByteData.sublistView(Uint8List.fromList(logo)),
      );
  ref.invalidate(myOrganizationsProvider);
}
