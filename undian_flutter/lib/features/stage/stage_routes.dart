import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/data/repository_providers.dart';
import '../../core/ui/async_view.dart';
import '../branding/branding.dart';
import '../events/event_providers.dart';
import '../organizations/organization_providers.dart';
import 'gateway/demo_gateway.dart';
import 'gateway/event_gateway.dart';
import 'stage_controller.dart';
import 'stage_page.dart';

/// Panggung mode demo: data contoh, undian lokal, identitas bisa diubah langsung.
class DemoStageRoute extends StatefulWidget {
  const DemoStageRoute({super.key});

  @override
  State<DemoStageRoute> createState() => _DemoStageRouteState();
}

class _DemoStageRouteState extends State<DemoStageRoute> {
  final _gateway = DemoStageGateway();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        stageGatewayProvider.overrideWithValue(_gateway),
        stageBrandingProvider.overrideWith((ref) => ref.watch(brandingProvider)),
      ],
      child: const StagePage(),
    );
  }
}

/// Panggung untuk acara sungguhan. Undian dijalankan dan dicatat oleh server, atau oleh
/// penyimpanan di laptop pada mode offline.
class EventStageRoute extends ConsumerWidget {
  const EventStageRoute({super.key, required this.organizationId, required this.eventId});

  final int organizationId;
  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (organizationId: organizationId, eventId: eventId);
    final organization = ref.watch(organizationProvider(organizationId));
    final event = ref.watch(eventProvider(key));
    return Scaffold(
      backgroundColor: Colors.black,
      body: AsyncView(
        value: organization,
        onRetry: () => ref.invalidate(myOrganizationsProvider),
        data: (org) => AsyncView(
          value: event,
          onRetry: () => ref.invalidate(eventsProvider(organizationId)),
          data: (event) => org.canDraw
              ? _ServerStage(organization: org.organization, event: event)
              : const ErrorView(message: 'Peran Anda hanya untuk melihat; panggung hanya untuk admin dan operator.'),
        ),
      ),
    );
  }
}

class _ServerStage extends ConsumerStatefulWidget {
  const _ServerStage({required this.organization, required this.event});

  final Organization organization;
  final DrawEvent event;

  @override
  ConsumerState<_ServerStage> createState() => _ServerStageState();
}

class _ServerStageState extends ConsumerState<_ServerStage> {
  late final _gateway = EventStageGateway(ref.read(repositoryProvider), widget.event);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        stageGatewayProvider.overrideWithValue(_gateway),
        stageBrandingProvider.overrideWithValue(widget.organization.toBranding(eventTitle: widget.event.name)),
      ],
      child: const StagePage(),
    );
  }
}
