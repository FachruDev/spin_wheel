import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/ui/async_view.dart';
import 'brand_widgets.dart';
import 'branding.dart';

/// Batas ukuran logo; sama dengan batas di server.
const maxLogoBytes = 300 * 1024;

/// Membuka pengaturan identitas. [onSave] dipanggil dengan nilai baru; dialog menutup
/// setelah [onSave] selesai tanpa error.
Future<void> showBrandingDialog(
  BuildContext context, {
  required Branding initial,
  required Future<void> Function(Branding branding) onSave,
  bool showEventTitle = true,
}) => showDialog<void>(
  context: context,
  builder: (_) => BrandingDialog(initial: initial, onSave: onSave, showEventTitle: showEventTitle),
);

/// Pengaturan identitas organisasi: nama, judul acara, warna, dan logo.
class BrandingDialog extends StatefulWidget {
  const BrandingDialog({super.key, required this.initial, required this.onSave, this.showEventTitle = true});

  final Branding initial;
  final Future<void> Function(Branding branding) onSave;
  final bool showEventTitle;

  @override
  State<BrandingDialog> createState() => _BrandingDialogState();
}

class _BrandingDialogState extends State<BrandingDialog> {
  late final _organization = TextEditingController(text: widget.initial.organizationName);
  late final _event = TextEditingController(text: widget.initial.eventTitle);
  late BrandPalette _palette = widget.initial.palette;
  late Uint8List? _logo = widget.initial.logoBytes;
  String? _logoError;
  var _saving = false;

  @override
  void dispose() {
    _organization.dispose();
    _event.dispose();
    super.dispose();
  }

  Branding get _draft => Branding(
    organizationName: _organization.text.trim().isEmpty ? 'Nama Perusahaan' : _organization.text.trim(),
    eventTitle: _event.text.trim(),
    palette: _palette,
    logoBytes: _logo,
  );

  Future<void> _pickLogo() async {
    final file = await FilePicker.pickFile(dialogTitle: 'Pilih logo', type: FileType.image);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      if (bytes.length > maxLogoBytes) {
        _logoError = 'Ukuran logo ${(bytes.length / 1024).round()} KB; maksimal 300 KB.';
      } else {
        _logoError = null;
        _logo = bytes;
      }
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_draft);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palettes = [...brandPalettes, if (!brandPalettes.contains(_palette)) _palette];
    return AlertDialog(
      title: const Text('Tampilan & identitas'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _organization,
                decoration: const InputDecoration(labelText: 'Nama organisasi / perusahaan'),
                onChanged: (_) => setState(() {}),
              ),
              if (widget.showEventTitle) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _event,
                  decoration: const InputDecoration(labelText: 'Judul acara'),
                ),
              ],
              const SizedBox(height: 24),
              Text('Warna', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final palette in palettes)
                    ChoiceChip(
                      selected: palette == _palette,
                      onSelected: (_) => setState(() => _palette = palette),
                      avatar: _Swatch(palette: palette),
                      label: Text(palette.name),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Logo', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  BrandLogo(branding: _draft, size: 64),
                  const SizedBox(width: 16),
                  FilledButton.tonalIcon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.upload_rounded),
                    label: const Text('Pilih logo'),
                  ),
                  if (_logo != null) ...[
                    const SizedBox(width: 8),
                    TextButton(onPressed: () => setState(() => _logo = null), child: const Text('Hapus')),
                  ],
                ],
              ),
              if (_logoError case final error?) ...[
                const SizedBox(height: 8),
                Text(error, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 8),
              Text('PNG/JPG, maksimal 300 KB.', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.palette});

  final BrandPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(colors: [palette.primary, palette.accent, palette.primary]),
      ),
    );
  }
}
