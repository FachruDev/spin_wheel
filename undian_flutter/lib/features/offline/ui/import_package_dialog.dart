import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/async_view.dart';
import '../../../core/ui/format.dart';
import '../offline_providers.dart';
import '../package/event_package.dart';
import '../store/offline_files.dart';
import '../store/offline_repository.dart';
import 'package_actions.dart';

/// Mengimpor paket acara ke mode offline: dari salinan otomatis di laptop ini atau dari file
/// `.undian` (mis. dibawa dengan flashdisk dari laptop lain). Mengembalikan acara hasil impor.
Future<DrawEvent?> showImportPackageDialog(BuildContext context, {required OfflineRepository repository}) =>
    showDialog<DrawEvent>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImportPackageDialog(repository: repository),
    );

class ImportPackageDialog extends ConsumerStatefulWidget {
  const ImportPackageDialog({super.key, required this.repository, this.initialPackage});

  final OfflineRepository repository;

  /// Untuk tes: langsung ke langkah konfirmasi dengan paket ini.
  final EventPackage? initialPackage;

  @override
  ConsumerState<ImportPackageDialog> createState() => _ImportPackageDialogState();
}

typedef _Backup = ({BackupFile file, EventPackage? package});

class _ImportPackageDialogState extends ConsumerState<ImportPackageDialog> {
  List<_Backup>? _backups;
  late EventPackage? _package = widget.initialPackage;
  var _replace = true;
  var _busy = false;
  String? _error;

  OfflineFiles? get _files => ref.read(offlineFilesProvider);

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final files = _files;
    if (files == null) return setState(() => _backups = const []);
    final list = <_Backup>[];
    for (final file in await files.listBackups()) {
      try {
        list.add((file: file, package: EventPackage.decode(await files.readFile(file.path))));
      } catch (_) {
        list.add((file: file, package: null));
      }
    }
    if (mounted) setState(() => _backups = list);
  }

  Future<void> _pickFile() async {
    setState(() => _error = null);
    final file = await FilePicker.pickFile(
      dialogTitle: 'Pilih paket acara',
      type: FileType.custom,
      allowedExtensions: const [EventPackage.fileExtension],
    );
    if (file == null) return;
    try {
      final package = EventPackage.decode(await file.readAsBytes());
      if (mounted) setState(() => _package = package);
    } catch (e) {
      if (mounted) setState(() => _error = describeError(e));
    }
  }

  Future<void> _openBackupFolder() async {
    final files = _files;
    if (files == null) return;
    await launchUrl(Uri.directory(await files.backupFolder()));
  }

  Future<void> _import(EventPackage package, DrawEvent? existing) async {
    setState(() => _busy = true);
    try {
      final event = await widget.repository.importPackage(
        package,
        replaceEventId: existing != null && _replace ? existing.id : null,
      );
      if (mounted) Navigator.of(context).pop(event);
    } catch (e) {
      if (mounted) setState(() => _error = describeError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final package = _package;
    return AlertDialog(
      title: const Text('Impor paket acara'),
      content: SizedBox(width: 560, child: package == null ? _chooser(context) : _confirmation(context, package)),
      actions: package == null
          ? [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal'))]
          : _confirmActions(package),
    );
  }

  Widget _chooser(BuildContext context) {
    final theme = Theme.of(context);
    final backups = _backups;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Pilih salinan otomatis dari server, atau file .undian yang diekspor dari laptop lain '
          '(mis. dibawa dengan flashdisk).',
        ),
        const SizedBox(height: 16),
        Text('Salinan otomatis di laptop ini', style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        if (backups == null)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (backups.isEmpty)
          Text(
            'Belum ada. Salinan dibuat otomatis setiap kali acara dibuka di aplikasi ini saat online.',
            style: theme.textTheme.bodySmall,
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final b in backups)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history_rounded),
                    enabled: b.package != null,
                    title: Text(
                      b.package == null ? b.file.name : '${b.package!.organization.name} – ${b.package!.event.name}',
                    ),
                    subtitle: Text(
                      b.package == null
                          ? 'File rusak, tidak bisa dibuka'
                          : 'Disimpan ${formatDateTime(b.file.modified)} · ${packageSummary(b.package!)}',
                    ),
                    onTap: b.package == null ? null : () => setState(() => _package = b.package),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_open_rounded),
              label: const Text('Pilih file paket…'),
            ),
            if (backups != null && backups.isNotEmpty)
              OutlinedButton.icon(
                onPressed: _openBackupFolder,
                icon: const Icon(Icons.folder_open_rounded),
                label: const Text('Buka folder salinan'),
              ),
          ],
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
      ],
    );
  }

  DrawEvent? _existing(EventPackage package) => widget.repository.eventsWithLineage(package.lineageId).firstOrNull;

  Widget _confirmation(BuildContext context, EventPackage package) {
    final theme = Theme.of(context);
    final existing = _existing(package);
    final existingInfo = existing == null ? null : widget.repository.eventInfo(existing.id!);
    final localIsNewer = existingInfo != null && existingInfo.changedAt.isAfter(package.exportedAt);
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: theme.textTheme.bodySmall)),
          Expanded(child: Text(value)),
        ],
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row('Organisasi', package.organization.name),
        row('Acara', package.event.name),
        row('Isi', packageSummary(package)),
        row('Disimpan dari', package.exportedFrom),
        row('Waktu', formatDateTime(package.exportedAt.toLocal())),
        if (existing != null) ...[
          const SizedBox(height: 16),
          Text('Acara ini sudah ada di laptop ini', style: theme.textTheme.titleSmall),
          if (localIsNewer)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Perhatian: data di laptop ini diubah ${formatDateTime(existingInfo.changedAt.toLocal())}, '
                'lebih baru dari paket. Mengganti akan menghilangkan perubahan tersebut.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          RadioGroup<bool>(
            groupValue: _replace,
            onChanged: (v) => setState(() => _replace = v ?? true),
            child: const Column(
              children: [
                RadioListTile(
                  value: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Ganti data lama dengan paket ini'),
                ),
                RadioListTile(
                  value: false,
                  contentPadding: EdgeInsets.zero,
                  title: Text('Simpan sebagai acara terpisah'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'Lanjutkan undian hanya di satu laptop. Bila pindah laptop, ekspor paket terbaru dari laptop '
          'lama lalu berhenti mengundi di sana.',
          style: theme.textTheme.bodySmall,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
      ],
    );
  }

  List<Widget> _confirmActions(EventPackage package) => [
    TextButton(
      onPressed: _busy || widget.initialPackage != null ? null : () => setState(() => _package = null),
      child: const Text('Kembali'),
    ),
    FilledButton(
      key: const ValueKey('import-package'),
      onPressed: _busy ? null : () => _import(package, _existing(package)),
      child: _busy
          ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Text('Impor'),
    ),
  ];
}
