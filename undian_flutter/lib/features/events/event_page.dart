import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/repository_providers.dart';
import '../../core/ui/async_view.dart';
import '../../core/ui/format.dart';
import '../offline/backup/auto_backup.dart';
import '../offline/offline_providers.dart';
import '../offline/ui/offline_widgets.dart';
import '../offline/ui/package_actions.dart';
import '../organizations/organization_providers.dart';
import '../participants/participants_tab.dart';
import '../prizes/prizes_tab.dart';
import '../winners/winners_tab.dart';
import 'event_providers.dart';

/// Satu acara: tab Peserta, Hadiah, Pemenang, tombol ekspor paket, dan tombol membuka panggung.
class EventPage extends ConsumerStatefulWidget {
  const EventPage({super.key, required this.organizationId, required this.eventId});

  final int organizationId;
  final int eventId;

  @override
  ConsumerState<EventPage> createState() => _EventPageState();
}

class _EventPageState extends ConsumerState<EventPage> {
  int get _organizationId => widget.organizationId;
  int get _eventId => widget.eventId;

  @override
  void initState() {
    super.initState();
    // Online: perbarui salinan otomatis acara ini di laptop setiap kali halamannya dibuka.
    if (!ref.read(isOfflineProvider)) {
      ref.read(serverRepositoryProvider).notifyOpened(_organizationId, _eventId);
    }
  }

  Future<void> _openStage() async {
    await context.push('/o/$_organizationId/a/$_eventId/panggung');
    // Data mungkin berubah selama di panggung.
    ref
      ..invalidate(winnersProvider(_eventId))
      ..invalidate(prizesProvider(_eventId));
  }

  @override
  Widget build(BuildContext context) {
    final key = (organizationId: _organizationId, eventId: _eventId);
    final organization = ref.watch(organizationProvider(_organizationId));
    final event = ref.watch(eventProvider(key));
    final member = organization.value;
    final offline = ref.watch(isOfflineProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go('/o/$_organizationId')),
          title: TitleWithOfflineBadge(event.value?.name ?? 'Acara'),
          actions: [
            if (!offline) _BackupStatus(eventId: _eventId),
            if (member?.canDraw ?? false)
              IconButton(
                key: const ValueKey('export-package'),
                tooltip: 'Ekspor paket acara (untuk laptop lain / mode offline)',
                onPressed: event.hasValue
                    ? () => exportEventPackage(context, ref, organizationId: _organizationId, eventId: _eventId)
                    : null,
                icon: const Icon(Icons.file_upload_rounded),
              ),
            if (member?.canDraw ?? false)
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 12),
                child: FilledButton.icon(
                  onPressed: event.hasValue ? _openStage : null,
                  icon: const Icon(Icons.slideshow_rounded),
                  label: const Text('Buka panggung'),
                ),
              ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.groups_rounded), text: 'Peserta'),
              Tab(icon: Icon(Icons.card_giftcard_rounded), text: 'Hadiah'),
              Tab(icon: Icon(Icons.emoji_events_rounded), text: 'Pemenang'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (offline) OfflineEventBanner(eventId: _eventId),
            Expanded(
              child: AsyncView(
                value: event,
                onRetry: () => ref.invalidate(eventsProvider(_organizationId)),
                data: (event) => TabBarView(
                  children: [
                    ParticipantsTab(eventId: _eventId, canManage: member?.canManage ?? false),
                    PrizesTab(event: event, canManage: member?.canManage ?? false),
                    WinnersTab(event: event, organization: member?.organization, canDraw: member?.canDraw ?? false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Online di desktop: kapan salinan otomatis acara ini terakhir disimpan di laptop.
class _BackupStatus extends ConsumerWidget {
  const _BackupStatus({required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(offlineFilesProvider) == null) return const SizedBox.shrink();
    final savedAt = ref.watch(autoBackupProvider.select((m) => m[eventId]));
    return Tooltip(
      message:
          'Salinan seluruh data acara disimpan otomatis di laptop ini. Bila server bermasalah, buka '
          'Mode offline lalu impor salinan ini.',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Icon(savedAt == null ? Icons.cloud_sync_outlined : Icons.offline_pin_rounded, size: 18),
            const SizedBox(width: 6),
            Text(
              savedAt == null ? 'Menyimpan salinan…' : 'Salinan offline ${formatTime(savedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
