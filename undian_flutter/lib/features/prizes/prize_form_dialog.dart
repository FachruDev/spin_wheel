import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:undian_client/undian_client.dart';

/// Formulir tambah/ubah hadiah. Mengembalikan hadiah yang siap disimpan, atau null bila batal.
Future<EventPrize?> showPrizeForm(
  BuildContext context, {
  required EventPrize initial,
  required Map<String, int> groupCounts,
  required int Function(EventPrize draft) eligibleCount,
}) => showDialog<EventPrize>(
  context: context,
  builder: (_) => _PrizeFormDialog(initial: initial, groupCounts: groupCounts, eligibleCount: eligibleCount),
);

class _PrizeFormDialog extends StatefulWidget {
  const _PrizeFormDialog({required this.initial, required this.groupCounts, required this.eligibleCount});

  final EventPrize initial;
  final Map<String, int> groupCounts;
  final int Function(EventPrize draft) eligibleCount;

  @override
  State<_PrizeFormDialog> createState() => _PrizeFormDialogState();
}

class _PrizeFormDialogState extends State<_PrizeFormDialog> {
  late final _name = TextEditingController(text: widget.initial.name);
  late final _quantity = TextEditingController(text: '${widget.initial.quantity}');
  late PrizeKind _kind = widget.initial.kind;
  late bool _openToAll = widget.initial.openToAll;
  late final Set<String> _groups = widget.initial.eligibleGroups.toSet();

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  EventPrize get _draft => widget.initial.copyWith(
    name: _name.text.trim(),
    kind: _kind,
    quantity: int.tryParse(_quantity.text) ?? 0,
    openToAll: _openToAll,
    eligibleGroups: _groups.toList()..sort(),
  );

  String? get _problem {
    if (_name.text.trim().isEmpty) return 'Nama hadiah wajib diisi.';
    if ((int.tryParse(_quantity.text) ?? 0) < 1) return 'Jumlah unit minimal 1.';
    if (!_openToAll && _groups.isEmpty) return 'Pilih minimal satu grup, atau buka untuk semua peserta.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final problem = _problem;
    // Grup yang dipakai hadiah tapi sudah tidak dimiliki peserta tetap ditampilkan.
    final groups = {...widget.groupCounts.keys, ..._groups}.toList()..sort();
    return AlertDialog(
      title: Text(widget.initial.id == null ? 'Tambah hadiah' : 'Ubah hadiah'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nama hadiah', hintText: 'mis. Smart TV 50 inci'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SegmentedButton<PrizeKind>(
                    segments: const [
                      ButtonSegment(value: PrizeKind.doorprize, label: Text('Doorprize')),
                      ButtonSegment(value: PrizeKind.grandprize, label: Text('Grand prize')),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (s) => setState(() => _kind = s.first),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(labelText: 'Jumlah unit'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Peserta yang berhak', style: theme.textTheme.labelLarge),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _openToAll,
                onChanged: (v) => setState(() => _openToAll = v),
                title: const Text('Semua peserta'),
              ),
              if (!_openToAll) ...[
                if (groups.isEmpty)
                  Text('Belum ada grup. Import peserta dengan kolom Grup dulu.', style: theme.textTheme.bodySmall)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final g in groups)
                        FilterChip(
                          selected: _groups.contains(g),
                          label: Text('$g (${widget.groupCounts[g] ?? 0})'),
                          onSelected: (on) => setState(() => on ? _groups.add(g) : _groups.remove(g)),
                        ),
                    ],
                  ),
              ],
              const SizedBox(height: 16),
              Text(
                problem ?? '${widget.eligibleCount(_draft)} peserta berhak saat ini.',
                style: TextStyle(color: problem == null ? theme.colorScheme.primary : theme.colorScheme.error),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: problem == null ? () => Navigator.pop(context, _draft) : null,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
