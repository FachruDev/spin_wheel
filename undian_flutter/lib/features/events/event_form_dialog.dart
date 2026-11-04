import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/data/repository_providers.dart';
import '../../core/ui/async_view.dart';
import '../../core/ui/format.dart';
import 'event_providers.dart';

/// Isian formulir acara. [date] adalah tanggal lokal (tanpa jam).
typedef EventInput = ({String name, DateTime? date, bool allowMultipleWins});

/// Formulir buat acara, atau ubah acara bila [initial] diisi. Null bila dibatalkan.
Future<EventInput?> showEventFormDialog(BuildContext context, {DrawEvent? initial}) => showDialog<EventInput>(
  context: context,
  builder: (_) => EventFormDialog(initial: initial),
);

/// Mengubah nama, tanggal, atau aturan menang [event] lewat formulir.
Future<void> editEvent(BuildContext context, WidgetRef ref, DrawEvent event) async {
  final input = await showEventFormDialog(context, initial: event);
  if (input == null || !context.mounted) return;
  try {
    await ref
        .read(repositoryProvider)
        .updateEvent(
          event.id!,
          name: input.name,
          eventDate: input.date?.toUtc(),
          allowMultipleWins: input.allowMultipleWins,
        );
    ref.invalidate(eventsProvider(event.organizationId));
    if (context.mounted) showInfoSnack(context, 'Acara "${input.name}" disimpan.');
  } catch (e) {
    if (context.mounted) showErrorSnack(context, e);
  }
}

class EventFormDialog extends StatefulWidget {
  const EventFormDialog({super.key, this.initial});

  final DrawEvent? initial;

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  late final _name = TextEditingController(text: widget.initial?.name);
  late DateTime? _date = _localDay(widget.initial?.eventDate);
  late var _allowMultipleWins = widget.initial?.allowMultipleWins ?? false;

  bool get _editing => widget.initial != null;

  static DateTime? _localDay(DateTime? date) {
    final local = date?.toLocal();
    return local == null ? null : DateTime(local.year, local.month, local.day);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _date ?? DateTime(now.year, now.month, now.day);
    var first = DateTime(now.year - 1);
    if (initial.isBefore(first)) first = initial;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop<EventInput>(context, (name: name, date: _date, allowMultipleWins: _allowMultipleWins));
  }

  @override
  Widget build(BuildContext context) {
    final valid = _name.text.trim().isNotEmpty;
    final ruleChanged = _editing && _allowMultipleWins != widget.initial!.allowMultipleWins;
    return AlertDialog(
      title: Text(_editing ? 'Ubah acara' : 'Buat acara'),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const ValueKey('event-name'),
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nama acara', hintText: 'mis. HUT 2026'),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_month_rounded),
              title: Text(_date == null ? 'Tanggal acara (opsional)' : formatDate(_date!)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_date != null)
                    IconButton(
                      tooltip: 'Kosongkan tanggal',
                      onPressed: () => setState(() => _date = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  TextButton(onPressed: _pickDate, child: const Text('Pilih')),
                ],
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _allowMultipleWins,
              onChanged: (v) => setState(() => _allowMultipleWins = v),
              title: const Text('Boleh menang lebih dari sekali'),
              subtitle: Text(
                ruleChanged
                    ? 'Berlaku untuk undian berikutnya; pemenang yang sudah ada tidak berubah.'
                    : 'Jika mati, pemenang tidak ikut undian hadiah berikutnya.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: valid ? _submit : null, child: Text(_editing ? 'Simpan' : 'Buat')),
      ],
    );
  }
}
