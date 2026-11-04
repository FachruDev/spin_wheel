import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/data/repository_providers.dart';
import '../../core/ui/async_view.dart';
import '../../core/ui/dialogs.dart';
import '../events/event_providers.dart';

/// Formulir tambah peserta, atau ubah/hapus peserta bila [participant] diisi. Data langsung
/// disimpan; kesalahan (mis. NIK sudah terdaftar) tampil di dalam formulir.
Future<void> showParticipantForm(BuildContext context, {required int eventId, EventParticipant? participant}) =>
    showDialog<void>(
      context: context,
      builder: (_) => ParticipantFormDialog(eventId: eventId, participant: participant),
    );

class ParticipantFormDialog extends ConsumerStatefulWidget {
  const ParticipantFormDialog({super.key, required this.eventId, this.participant});

  final int eventId;
  final EventParticipant? participant;

  @override
  ConsumerState<ParticipantFormDialog> createState() => _ParticipantFormDialogState();
}

class _ParticipantFormDialogState extends ConsumerState<ParticipantFormDialog> {
  late final EventParticipant? _old = widget.participant;
  late final _nik = TextEditingController(text: _old?.nik);
  late final _name = TextEditingController(text: _old?.name);
  late final _area = TextEditingController(text: _old?.area);
  late final _department = TextEditingController(text: _old?.department);
  late final _status = TextEditingController(text: _old?.employmentStatus);
  late final _phone = TextEditingController(text: _old?.phone);
  late final _points = TextEditingController(text: '${_old?.points ?? 1}');
  final _newGroup = TextEditingController();
  late final Set<String> _groups = {...?_old?.groups};
  var _saving = false;
  String? _error;

  bool get _editing => _old != null;

  @override
  void dispose() {
    for (final c in [_nik, _name, _area, _department, _status, _phone, _points, _newGroup]) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _problem {
    if (_nik.text.trim().isEmpty) return 'NIK wajib diisi.';
    if (_name.text.trim().isEmpty) return 'Nama wajib diisi.';
    if ((int.tryParse(_points.text.trim()) ?? 0) < 1) return 'Poin minimal 1.';
    return null;
  }

  ParticipantInput get _input => ParticipantInput(
    nik: _nik.text.trim(),
    name: _name.text.trim(),
    area: _area.text.trim(),
    department: _department.text.trim(),
    employmentStatus: _status.text.trim(),
    phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
    points: int.parse(_points.text.trim()),
    groups: _groups.toList()..sort(),
  );

  void _addGroup() {
    final group = _newGroup.text.trim();
    if (group.isEmpty) return;
    setState(() {
      _groups.add(group);
      _newGroup.clear();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await action();
      ref.invalidate(participantsProvider(widget.eventId));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = describeError(e);
        });
      }
    }
  }

  Future<void> _save() async {
    if (_problem != null || _saving) return;
    final repository = ref.read(repositoryProvider);
    final input = _input;
    await _run(() async {
      final old = _old;
      if (old == null) {
        await repository.addParticipant(widget.eventId, input);
      } else {
        await repository.updateParticipant(old, input);
      }
    });
  }

  Future<void> _delete() async {
    final old = _old!;
    final ok = await confirm(
      context,
      title: 'Hapus ${old.name}?',
      message: 'Peserta ${old.nik} dihapus dari acara ini. Peserta yang sudah pernah terundi tidak bisa dihapus.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !mounted) return;
    await _run(() => ref.read(repositoryProvider).deleteParticipant(old));
  }

  Widget _field(TextEditingController controller, String label, {Key? key, String? hint, bool autofocus = false}) =>
      TextField(
        key: key,
        controller: controller,
        autofocus: autofocus,
        decoration: InputDecoration(labelText: label, hintText: hint),
        onChanged: (_) => setState(() => _error = null),
        onSubmitted: (_) => _save(),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final problem = _problem;
    final participants = ref.watch(participantsProvider(widget.eventId)).value ?? const [];
    final prizes = ref.watch(prizesProvider(widget.eventId)).value ?? const [];
    final knownGroups = <String>{
      ...groupCounts(participants).keys,
      for (final p in prizes) ...p.eligibleGroups,
      ..._groups,
    }.toList()..sort();
    final saveButton = FilledButton(
      key: const ValueKey('participant-save'),
      onPressed: problem == null && !_saving ? _save : null,
      child: Text(_saving ? 'Menyimpan…' : 'Simpan'),
    );

    return AlertDialog(
      title: Text(_editing ? 'Ubah peserta' : 'Tambah peserta'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _nik,
                      'NIK / nomor undian',
                      key: const ValueKey('participant-nik'),
                      autofocus: !_editing,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 96,
                    child: TextField(
                      key: const ValueKey('participant-points'),
                      controller: _points,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Poin'),
                      onChanged: (_) => setState(() => _error = null),
                    ),
                  ),
                ],
              ),
              _field(_name, 'Nama', key: const ValueKey('participant-name'), autofocus: _editing),
              Row(
                children: [
                  Expanded(child: _field(_area, 'Area / lokasi', hint: 'mis. Bogor Plant')),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_department, 'Departemen')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _field(_status, 'Status karyawan', hint: 'mis. Pegawai Tetap')),
                  const SizedBox(width: 12),
                  Expanded(child: _field(_phone, 'No. HP (opsional)')),
                ],
              ),
              const SizedBox(height: 20),
              Text('Grup', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              Text('Menentukan hadiah yang boleh diikuti, mis. "Doorprize Bogor".', style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final g in knownGroups)
                    FilterChip(
                      label: Text(g),
                      selected: _groups.contains(g),
                      onSelected: (on) => setState(() => on ? _groups.add(g) : _groups.remove(g)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newGroup,
                      decoration: const InputDecoration(labelText: 'Grup lain', isDense: true),
                      onSubmitted: (_) => _addGroup(),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addGroup,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              if (_error case final error?) ...[
                const SizedBox(height: 16),
                Text(error, style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (_editing)
          TextButton.icon(
            key: const ValueKey('participant-delete'),
            onPressed: _saving ? null : _delete,
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Hapus'),
          ),
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Batal')),
        if (problem == null) saveButton else Tooltip(message: problem, child: saveButton),
      ],
    );
  }
}
