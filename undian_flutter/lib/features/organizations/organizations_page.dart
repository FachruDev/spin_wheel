import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/server/server_providers.dart';
import '../../core/ui/async_view.dart';
import '../../core/ui/dialogs.dart';
import '../branding/brand_widgets.dart';
import '../branding/branding_dialog.dart';
import 'organization_providers.dart';

/// Beranda setelah login: organisasi tempat pengguna menjadi anggota.
class OrganizationsPage extends ConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(myOrganizationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organisasi Saya'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/demo'),
            icon: const Icon(Icons.slideshow_rounded),
            label: const Text('Mode demo'),
          ),
          IconButton(
            tooltip: 'Keluar',
            onPressed: () => ref.read(clientProvider).auth.signOutDevice(),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Buat organisasi'),
      ),
      body: AsyncView(
        value: organizations,
        onRetry: () => ref.invalidate(myOrganizationsProvider),
        data: (list) => list.isEmpty
            ? EmptyView(
                icon: Icons.apartment_rounded,
                title: 'Belum ada organisasi',
                message: 'Buat organisasi untuk perusahaan atau komunitas Anda, lalu tambahkan acara undian.',
                action: FilledButton.icon(
                  onPressed: () => _create(context, ref),
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('Buat organisasi'),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [for (final item in list) _OrganizationCard(item: item)],
              ),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await askText(context, title: 'Buat organisasi', label: 'Nama perusahaan / organisasi');
    if (name == null || !context.mounted) return;
    try {
      final created = await ref.read(clientProvider).organization.create(name);
      ref.invalidate(myOrganizationsProvider);
      if (context.mounted) context.go('/o/${created.organization.id}');
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }
}

class _OrganizationCard extends ConsumerWidget {
  const _OrganizationCard({required this.item});

  final MyOrganization item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final org = item.organization;
    final branding = org.toBranding();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/o/${org.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              BrandLogo(branding: branding, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(org.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Peran: ${item.roleLabel}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (item.canManage)
                IconButton(
                  tooltip: 'Tampilan & identitas',
                  icon: const Icon(Icons.palette_outlined),
                  onPressed: () => showBrandingDialog(
                    context,
                    initial: branding,
                    showEventTitle: false,
                    onSave: (b) => saveOrganizationBranding(ref, org.id!, b),
                  ),
                ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
