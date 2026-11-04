import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/ui/async_view.dart';
import '../events/event_providers.dart';
import 'import/import_dialog.dart';
import 'participant_form_dialog.dart';

/// Daftar peserta acara, ringkasan grup, tombol tambah peserta, dan import Excel.
///
/// Admin bisa mengubah atau menghapus peserta dengan mengklik barisnya.
class ParticipantsTab extends ConsumerStatefulWidget {
  const ParticipantsTab({super.key, required this.eventId, required this.canManage});

  final int eventId;
  final bool canManage;

  @override
  ConsumerState<ParticipantsTab> createState() => _ParticipantsTabState();
}

class _ParticipantsTabState extends ConsumerState<ParticipantsTab> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final participants = ref.watch(participantsProvider(widget.eventId));
    final hasWinners = ref.watch(winnersProvider(widget.eventId)).value?.isNotEmpty ?? false;
    return AsyncView(
      value: participants,
      onRetry: () => ref.invalidate(participantsProvider(widget.eventId)),
      data: (list) {
        final importButton = FilledButton.icon(
          onPressed: () => showImportDialog(context, eventId: widget.eventId, hasWinners: hasWinners),
          icon: const Icon(Icons.upload_file_rounded),
          label: const Text('Import Excel'),
        );
        final addButton = OutlinedButton.icon(
          key: const ValueKey('add-participant'),
          onPressed: () => showParticipantForm(context, eventId: widget.eventId),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Tambah peserta'),
        );
        if (list.isEmpty) {
          return EmptyView(
            icon: Icons.groups_rounded,
            title: 'Belum ada peserta',
            message: widget.canManage
                ? 'Import daftar karyawan dari file Excel (kolom bebas, nanti tinggal dicocokkan), '
                      'atau tambahkan peserta satu per satu.'
                : 'Admin belum mengimpor peserta.',
            action: widget.canManage
                ? Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [importButton, addButton],
                  )
                : null,
          );
        }
        final filtered = _filter(list);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Cari nama, NIK, area, atau grup',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                  ),
                ),
                if (widget.canManage) ...[const SizedBox(width: 12), addButton, const SizedBox(width: 8), importButton],
              ],
            ),
            const SizedBox(height: 12),
            _GroupSummary(participants: list),
            const SizedBox(height: 12),
            PaginatedDataTable(
              key: ValueKey('$_query-${filtered.length}'),
              header: Text('${filtered.length} dari ${list.length} peserta'),
              rowsPerPage: 25,
              showCheckboxColumn: false,
              availableRowsPerPage: const [25],
              columns: const [
                DataColumn(label: Text('NIK')),
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Area')),
                DataColumn(label: Text('Departemen')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Poin'), numeric: true),
                DataColumn(label: Text('Grup')),
              ],
              source: _ParticipantSource(
                filtered,
                onEdit: widget.canManage
                    ? (p) => showParticipantForm(context, eventId: widget.eventId, participant: p)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  List<EventParticipant> _filter(List<EventParticipant> list) {
    if (_query.isEmpty) return list;
    return [
      for (final p in list)
        if ([p.nik, p.name, p.area, p.department, ...p.groups].any((v) => v.toLowerCase().contains(_query))) p,
    ];
  }
}

class _GroupSummary extends StatelessWidget {
  const _GroupSummary({required this.participants});

  final List<EventParticipant> participants;

  @override
  Widget build(BuildContext context) {
    final counts = groupCounts(participants);
    final noGroup = participants.where((p) => p.groups.isEmpty).length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final MapEntry(key: group, value: count) in counts.entries)
          Chip(avatar: const Icon(Icons.label_outline_rounded, size: 18), label: Text('$group · $count')),
        if (noGroup > 0)
          Chip(
            avatar: Icon(Icons.warning_amber_rounded, size: 18, color: Theme.of(context).colorScheme.error),
            label: Text('Tanpa grup · $noGroup'),
          ),
      ],
    );
  }
}

class _ParticipantSource extends DataTableSource {
  _ParticipantSource(this.items, {this.onEdit});

  final List<EventParticipant> items;
  final ValueChanged<EventParticipant>? onEdit;

  @override
  DataRow? getRow(int index) {
    if (index >= items.length) return null;
    final p = items[index];
    final edit = onEdit;
    return DataRow(
      onSelectChanged: edit == null ? null : (_) => edit(p),
      cells: [
        DataCell(Text(p.nik)),
        DataCell(Text(p.name)),
        DataCell(Text(p.area)),
        DataCell(Text(p.department)),
        DataCell(Text(p.employmentStatus)),
        DataCell(Text('${p.points}')),
        DataCell(Text(p.groups.join(', '))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  int get selectedRowCount => 0;
}
