import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/format.dart';
import '../../events/event_providers.dart';
import '../../organizations/organization_providers.dart';
import '../offline_providers.dart';
import 'import_package_dialog.dart';

/// Penanda di app bar bahwa aplikasi sedang di mode offline.
class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(Icons.cloud_off_rounded, size: 16, color: scheme.onTertiaryContainer),
      label: const Text('Mode offline'),
      labelStyle: TextStyle(color: scheme.onTertiaryContainer),
      backgroundColor: scheme.tertiaryContainer,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Judul app bar dengan [OfflineBadge] bila sedang offline.
class TitleWithOfflineBadge extends ConsumerWidget {
  const TitleWithOfflineBadge(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider);
    return Row(
      children: [
        Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
        if (offline) ...[const SizedBox(width: 12), const OfflineBadge()],
      ],
    );
  }
}

/// Membuka dialog impor paket, lalu langsung ke halaman acara hasil impor.
Future<void> importPackageAndOpen(BuildContext context, WidgetRef ref) async {
  final repository = ref.read(activeOfflineRepositoryProvider);
  if (repository == null) return;
  final event = await showImportPackageDialog(context, repository: repository);
  if (event == null) return;
  ref
    ..invalidate(myOrganizationsProvider)
    ..invalidate(eventsProvider(event.organizationId));
  if (context.mounted) context.go('/o/${event.organizationId}/a/${event.id}');
}

/// Keterangan acara di mode offline: asal data dan kapan terakhir berubah/diekspor.
class OfflineEventBanner extends ConsumerWidget {
  const OfflineEventBanner({super.key, required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(activeOfflineRepositoryProvider)?.eventInfo(eventId);
    if (info == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final exported = info.exportedAt;
    return Material(
      color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, size: 18, color: theme.colorScheme.onTertiaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Data tersimpan di laptop ini · ${info.origin} · diubah ${formatDateTime(info.changedAt.toLocal())}'
                '${exported == null ? '' : ' · diekspor ${formatDateTime(exported.toLocal())}'}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
