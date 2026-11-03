import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../../core/server/server_providers.dart';
import '../../../core/ui/async_view.dart';
import '../../events/event_providers.dart';
import 'column_mapping.dart';
import 'excel_table_reader.dart';
import 'import_mapping_view.dart';

/// Import peserta dari Excel: pilih file → cocokkan kolom → pratinjau → kirim ke server.
Future<void> showImportDialog(BuildContext context, {required int eventId, required bool hasWinners}) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImportDialog(eventId: eventId, hasWinners: hasWinners),
    );

class ImportDialog extends ConsumerStatefulWidget {
  const ImportDialog({super.key, required this.eventId, required this.hasWinners, this.initialFile});

  final int eventId;

  /// Acara yang sudah punya pemenang tidak boleh diganti total (server juga menolak).
  final bool hasWinners;

  /// File yang langsung dibuka tanpa dialog pilih file (dipakai integration test).
  final ({String name, List<int> bytes})? initialFile;

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  String? _fileName;
  List<SheetData> _sheets = const [];
  var _sheetIndex = 0;
  int? _headerRow;
  SheetTable? _table;
  ColumnMapping _mapping = {};
  var _replaceAll = false;
  var _working = false;
  String? _error;
  ImportResult? _result;

  List<MappedRow> get _rows => _table == null ? const [] : mapRows(_table!, _mapping);

  @override
  void initState() {
    super.initState();
    if (widget.initialFile case (:final name, :final bytes)) _open(name, bytes);
  }

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final file = await FilePicker.pickFile(
      dialogTitle: 'Pilih file Excel peserta',
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
    );
    if (file == null) return;
    setState(() => _working = true);
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _open(file.name, bytes));
  }

  void _open(String name, List<int> bytes) {
    try {
      final sheets = readWorkbook(bytes);
      if (sheets.isEmpty) throw const FormatException('File tidak berisi data.');
      _fileName = name;
      _sheets = sheets;
      _selectSheet(0);
    } catch (e) {
      _error =
          'File tidak bisa dibaca. Pastikan formatnya .xlsx (file .xls lama: buka di Excel lalu '
          '"Save As" .xlsx). Detail: $e';
    } finally {
      _working = false;
    }
  }

  void _selectSheet(int index, {int? headerRow}) {
    _sheetIndex = index;
    _headerRow = headerRow;
    _table = _sheets[index].table(headerRow: headerRow);
    _mapping = guessMapping(_table!);
  }

  Future<void> _submit() async {
    final valid = [for (final r in _rows) ?r.input];
    setState(() => _working = true);
    try {
      final result = await ref.read(clientProvider).participant.importRows(widget.eventId, valid, _replaceAll);
      ref.invalidate(participantsProvider(widget.eventId));
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = describeError(e));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return AlertDialog(
      title: const Text('Import peserta dari Excel'),
      content: SizedBox(
        width: 960,
        height: 600,
        child: result != null
            ? ImportResultView(result: result, skipped: _rows.where((r) => !r.isValid).length)
            : _table == null
            ? _pickView()
            : _mappingView(),
      ),
      actions: [
        if (result != null)
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Selesai'))
        else ...[
          TextButton(onPressed: _working ? null : () => Navigator.pop(context), child: const Text('Batal')),
          if (_table != null) ...[
            TextButton(onPressed: _working ? null : _pickFile, child: const Text('Ganti file')),
            _submitButton(),
          ],
        ],
      ],
    );
  }

  Widget _submitButton() {
    final problem = mappingProblem(_mapping);
    final validCount = _rows.where((r) => r.isValid).length;
    return FilledButton(
      onPressed: _working || problem != null || validCount == 0 ? null : _submit,
      child: _working
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : Text('Import $validCount peserta'),
    );
  }

  Widget _pickView() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.table_view_rounded, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          const Text(
            'Pakai file Excel apa saja (.xlsx), mis. data dari HRD. Urutan dan nama kolom bebas; '
            'Anda tinggal mencocokkan kolomnya di langkah berikutnya.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _working ? null : _pickFile,
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Pilih file Excel'),
          ),
          if (_working) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          if (_error case final error?)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                error,
                style: TextStyle(color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _mappingView() {
    final table = _table!;
    final sheet = _sheets[_sheetIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(avatar: const Icon(Icons.description_outlined, size: 18), label: Text(_fileName ?? '')),
            if (_sheets.length > 1)
              DropdownButton<int>(
                value: _sheetIndex,
                items: [
                  for (var i = 0; i < _sheets.length; i++)
                    DropdownMenuItem(value: i, child: Text('Sheet: ${_sheets[i].name}')),
                ],
                onChanged: (i) => setState(() => _selectSheet(i!)),
              ),
            DropdownButton<int>(
              value: _headerRow ?? sheet.detectedHeaderRow,
              items: [
                for (var i = 0; i < sheet.rows.length && i < 20; i++)
                  DropdownMenuItem(value: i, child: Text('Judul kolom di baris ${i + 1}')),
              ],
              onChanged: (i) => setState(() => _selectSheet(_sheetIndex, headerRow: i)),
            ),
            SegmentedButton<bool>(
              segments: [
                const ButtonSegment(value: false, label: Text('Tambah / perbarui')),
                ButtonSegment(value: true, label: const Text('Ganti semua'), enabled: !widget.hasWinners),
              ],
              selected: {_replaceAll},
              onSelectionChanged: (s) => setState(() => _replaceAll = s.first),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _replaceAll
              ? 'Ganti semua: peserta yang tidak ada di file ini akan dihapus dari acara.'
              : 'Tambah / perbarui: NIK yang sudah ada diperbarui, NIK baru ditambahkan, yang lain tetap.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_error case final error?)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        const SizedBox(height: 12),
        Expanded(
          child: ImportMappingView(
            table: table,
            mapping: _mapping,
            rows: _rows,
            onChanged: (mapping) => setState(() => _mapping = mapping),
          ),
        ),
      ],
    );
  }
}
