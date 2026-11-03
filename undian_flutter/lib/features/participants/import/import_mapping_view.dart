import 'package:flutter/material.dart';
import 'package:undian_client/undian_client.dart';

import 'column_mapping.dart';
import 'excel_table_reader.dart';

/// Pemetaan kolom (kiri) dan pratinjau hasilnya (kanan).
class ImportMappingView extends StatelessWidget {
  const ImportMappingView({
    super.key,
    required this.table,
    required this.mapping,
    required this.rows,
    required this.onChanged,
  });

  final SheetTable table;
  final ColumnMapping mapping;
  final List<MappedRow> rows;
  final ValueChanged<ColumnMapping> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 400, child: _columns(context)),
        const VerticalDivider(width: 32),
        Expanded(child: _preview(context)),
      ],
    );
  }

  Widget _columns(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Cocokkan kolom', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Text('Kolom wajib: NIK dan Nama. Kolom Grup boleh lebih dari satu.', style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            itemCount: table.columnCount,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, c) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(table.columnLabel(c), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                table.sample(c).isEmpty ? '(kosong)' : 'contoh: ${table.sample(c)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: DropdownButton<ImportField?>(
                value: mapping[c],
                hint: const Text('Abaikan'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Abaikan')),
                  for (final f in ImportField.values) DropdownMenuItem(value: f, child: Text(f.label)),
                ],
                onChanged: (field) => onChanged(_assign(c, field)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Isian selain Grup hanya boleh dipakai satu kolom; kolom lama dilepas otomatis.
  ColumnMapping _assign(int column, ImportField? field) {
    final next = Map.of(mapping)..remove(column);
    if (field == null) return next;
    if (field != ImportField.group) next.removeWhere((_, f) => f == field);
    return next..[column] = field;
  }

  Widget _preview(BuildContext context) {
    final theme = Theme.of(context);
    final problem = mappingProblem(mapping);
    final valid = rows.where((r) => r.isValid).toList();
    final invalid = rows.where((r) => !r.isValid).toList();
    if (problem != null) {
      return Center(
        child: Text(problem, style: TextStyle(color: theme.colorScheme.error)),
      );
    }
    return ListView(
      children: [
        Wrap(
          spacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text('${valid.length} baris siap'),
            ),
            if (invalid.isNotEmpty)
              Chip(
                avatar: Icon(Icons.error_outline_rounded, size: 18, color: theme.colorScheme.error),
                label: Text('${invalid.length} baris dilewati'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Pratinjau', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        for (final row in valid.take(6)) _PreviewTile(row.excelRow, row.input!),
        if (valid.length > 6) Text('… dan ${valid.length - 6} baris lainnya', style: theme.textTheme.bodySmall),
        if (invalid.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Baris yang dilewati', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final row in invalid.take(30))
            Text('Baris ${row.excelRow}: ${row.error}', style: theme.textTheme.bodySmall),
          if (invalid.length > 30) Text('… dan ${invalid.length - 30} lainnya', style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile(this.excelRow, this.input);

  final int excelRow;
  final ParticipantInput input;

  @override
  Widget build(BuildContext context) {
    final details = [
      input.nik,
      if (input.area.isNotEmpty) input.area,
      if (input.department.isNotEmpty) input.department,
      if (input.employmentStatus.isNotEmpty) input.employmentStatus,
      if (input.points > 1) '${input.points} poin',
    ].join(' · ');
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Text('$excelRow', style: Theme.of(context).textTheme.bodySmall),
      title: Text(input.name),
      subtitle: Text(input.groups.isEmpty ? '$details\nTanpa grup' : '$details\nGrup: ${input.groups.join(', ')}'),
      isThreeLine: true,
    );
  }
}

/// Ringkasan setelah server menyimpan data.
class ImportResultView extends StatelessWidget {
  const ImportResultView({super.key, required this.result, required this.skipped});

  final ImportResult result;

  /// Baris yang sudah dilewati di aplikasi sebelum dikirim.
  final int skipped;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        Icon(Icons.task_alt_rounded, size: 56, color: theme.colorScheme.primary),
        const SizedBox(height: 12),
        Text('Import selesai', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Text(
          '${result.inserted} peserta baru · ${result.updated} diperbarui · '
          '${skipped + result.rejected.length} baris dilewati',
          textAlign: TextAlign.center,
        ),
        if (result.rejected.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Ditolak server:', style: theme.textTheme.titleSmall),
          for (final message in result.rejected) Text(message, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}
