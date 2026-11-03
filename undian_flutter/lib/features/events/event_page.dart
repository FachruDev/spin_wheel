import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui/async_view.dart';
import '../organizations/organization_providers.dart';
import '../participants/participants_tab.dart';
import '../prizes/prizes_tab.dart';
import '../winners/winners_tab.dart';
import 'event_providers.dart';

/// Satu acara: tab Peserta, Hadiah, Pemenang, dan tombol membuka panggung.
class EventPage extends ConsumerWidget {
  const EventPage({super.key, required this.organizationId, required this.eventId});

  final int organizationId;
  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (organizationId: organizationId, eventId: eventId);
    final organization = ref.watch(organizationProvider(organizationId));
    final event = ref.watch(eventProvider(key));
    final member = organization.value;

    Future<void> openStage() async {
      await context.push('/o/$organizationId/a/$eventId/panggung');
      // Data mungkin berubah selama di panggung.
      ref
        ..invalidate(winnersProvider(eventId))
        ..invalidate(prizesProvider(eventId));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go('/o/$organizationId')),
          title: Text(event.value?.name ?? 'Acara'),
          actions: [
            if (member?.canDraw ?? false)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  onPressed: event.hasValue ? openStage : null,
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
        body: AsyncView(
          value: event,
          onRetry: () => ref.invalidate(eventsProvider(organizationId)),
          data: (event) => TabBarView(
            children: [
              ParticipantsTab(eventId: eventId, canManage: member?.canManage ?? false),
              PrizesTab(event: event, canManage: member?.canManage ?? false),
              WinnersTab(eventId: eventId, canDraw: member?.canDraw ?? false),
            ],
          ),
        ),
      ),
    );
  }
}
