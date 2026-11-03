import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/server/server_providers.dart';
import '../../core/ui/async_view.dart';
import '../../core/ui/format.dart';
import '../organizations/organization_providers.dart';
import 'event_providers.dart';

/// Daftar acara undian dalam satu organisasi.
class EventsPage extends ConsumerWidget {
  const EventsPage({super.key, required this.organizationId});

  final int organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organization = ref.watch(organizationProvider(organizationId));
    final events = ref.watch(eventsProvider(organizationId));
    final canManage = organization.value?.canManage ?? false;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go('/')),
        title: Text(organization.value?.organization.name ?? 'Acara'),
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
                        subtitle: Text(_subtitle(event)),
                        trailing: const Icon(Icons.chevron_right_rounded),
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

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final input = await showDialog<_NewEvent>(context: context, builder: (_) => const _NewEventDialog());
    if (input == null || !context.mounted) return;
    try {
      final event = await ref
          .read(clientProvider)
          .event
          .create(organizationId, input.name, input.date?.toUtc(), input.allowMultipleWins);
      ref.invalidate(eventsProvider(organizationId));
      if (context.mounted) context.go('/o/$organizationId/a/${event.id}');
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }
}

typedef _NewEvent = ({String name, DateTime? date, bool allowMultipleWins});

class _NewEventDialog extends StatefulWidget {
  const _NewEventDialog();

  @override
  State<_NewEventDialog> createState() => _NewEventDialogState();
}

class _NewEventDialogState extends State<_NewEventDialog> {
  final _name = TextEditingController();
  DateTime? _date;
  var _allowMultipleWins = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    final valid = _name.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('Buat acara'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nama acara', hintText: 'mis. HUT 2026'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(_date == null ? 'Tanggal acara (opsional)' : formatDate(_date!)),
              trailing: TextButton(onPressed: _pickDate, child: const Text('Pilih')),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _allowMultipleWins,
              onChanged: (v) => setState(() => _allowMultipleWins = v),
              title: const Text('Boleh menang lebih dari sekali'),
              subtitle: const Text('Jika mati, pemenang tidak ikut undian hadiah berikutnya.'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: valid
              ? () => Navigator.pop(context, (
                  name: _name.text.trim(),
                  date: _date,
                  allowMultipleWins: _allowMultipleWins,
                ))
              : null,
          child: const Text('Buat'),
        ),
      ],
    );
  }
}
