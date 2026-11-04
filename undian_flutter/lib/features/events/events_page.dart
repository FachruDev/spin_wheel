import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/data/repository_providers.dart';
import '../../core/ui/async_view.dart';
import '../../core/ui/dialogs.dart';
import '../../core/ui/format.dart';
import '../offline/offline_providers.dart';
import '../offline/ui/offline_widgets.dart';
import '../organizations/organization_providers.dart';
import 'event_form_dialog.dart';
import 'event_providers.dart';

enum _EventAction { edit, deleteOffline }

/// Daftar acara undian dalam satu organisasi.
class EventsPage extends ConsumerWidget {
  const EventsPage({super.key, required this.organizationId});

  final int organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organization = ref.watch(organizationProvider(organizationId));
    final events = ref.watch(eventsProvider(organizationId));
    final canManage = organization.value?.canManage ?? false;
    final offline = ref.watch(activeOfflineRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: TitleWithOfflineBadge(organization.value?.organization.name ?? 'Acara'),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _create(context, ref),
              icon: const Icon(Icons.event_rounded),
              label: const Text('Buat acara'),
            )
          : null,
      body: AsyncView(
        value: events,
        onRetry: () => ref.invalidate(eventsProvider(organizationId)),
        data: (list) => list.isEmpty
            ? EmptyView(
                icon: Icons.celebration_rounded,
                title: 'Belum ada acara',
                message: canManage
                    ? 'Buat acara, mis. "HUT 2026" atau "RAT Koperasi 2026", lalu import peserta dan atur hadiahnya.'
                    : 'Admin organisasi belum membuat acara.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                children: [
                  for (final event in list)
                    Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: const Icon(Icons.celebration_rounded),
                        title: Text(event.name),
                        subtitle: Text(
                          [
                            _subtitle(event),
                            if (offline?.eventInfo(event.id!) case final info?) info.origin,
                          ].join('\n'),
                        ),
                        isThreeLine: offline != null,
                        trailing: canManage || offline != null
                            ? PopupMenuButton<_EventAction>(
                                key: ValueKey('event-menu-${event.id}'),
                                tooltip: 'Aksi acara',
                                onSelected: (action) => switch (action) {
                                  _EventAction.edit => editEvent(context, ref, event),
                                  _EventAction.deleteOffline => _deleteOffline(context, ref, event),
                                },
                                itemBuilder: (_) => [
                                  if (canManage)
                                    const PopupMenuItem(
                                      value: _EventAction.edit,
                                      child: ListTile(leading: Icon(Icons.edit_rounded), title: Text('Ubah acara')),
                                    ),
                                  if (offline != null)
                                    const PopupMenuItem(
                                      value: _EventAction.deleteOffline,
                                      child: ListTile(
                                        leading: Icon(Icons.delete_outline_rounded),
                                        title: Text('Hapus dari laptop ini'),
                                      ),
                                    ),
                                ],
                              )
                            : const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.go('/o/$organizationId/a/${event.id}'),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  String _subtitle(DrawEvent event) {
    final date = event.eventDate;
    final parts = [
      if (date != null) formatDate(date.toLocal()),
      if (event.allowMultipleWins) 'boleh menang lebih dari sekali',
    ];
    return parts.isEmpty ? 'Tanggal belum diatur' : parts.join(' · ');
  }

  /// Mode offline: menghapus salinan acara dari laptop ini (data di server tidak tersentuh).
  Future<void> _deleteOffline(BuildContext context, WidgetRef ref, DrawEvent event) async {
    final repository = ref.read(activeOfflineRepositoryProvider);
    if (repository == null) return;
    final ok = await confirm(
      context,
      title: 'Hapus "${event.name}" dari laptop ini?',
      message:
          'Peserta, hadiah, dan pemenang acara ini di laptop ini ikut terhapus. Ekspor paketnya dulu bila '
          'datanya masih dibutuhkan.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await repository.deleteEvent(event.id!);
      ref.invalidate(eventsProvider(organizationId));
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final input = await showEventFormDialog(context);
    if (input == null || !context.mounted) return;
    try {
      final event = await ref
          .read(repositoryProvider)
          .createEvent(
            organizationId,
            name: input.name,
            eventDate: input.date?.toUtc(),
            allowMultipleWins: input.allowMultipleWins,
          );
      ref.invalidate(eventsProvider(organizationId));
      if (context.mounted) context.go('/o/$organizationId/a/${event.id}');
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }
}
