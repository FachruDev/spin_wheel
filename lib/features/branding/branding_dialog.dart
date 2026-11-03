import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brand_widgets.dart';
import 'branding.dart';

Future<void> showBrandingDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const BrandingDialog());

/// Pengaturan identitas organisasi: nama, judul acara, warna, dan logo.
class BrandingDialog extends ConsumerStatefulWidget {
  const BrandingDialog({super.key});

  @override
  ConsumerState<BrandingDialog> createState() => _BrandingDialogState();
}

class _BrandingDialogState extends ConsumerState<BrandingDialog> {
  late final TextEditingController _organization;
  late final TextEditingController _event;
  late BrandPalette _palette;
  Uint8List? _logo;

  @override
  void initState() {
    super.initState();
    final branding = ref.read(brandingProvider);
    _organization = TextEditingController(text: branding.organizationName);
    _event = TextEditingController(text: branding.eventTitle);
    _palette = branding.palette;
    _logo = branding.logoBytes;
  }

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
    if (mounted) setState(() => _logo = bytes);
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 12),
              TextField(
                controller: _event,
                decoration: const InputDecoration(labelText: 'Judul acara'),
              ),
              const SizedBox(height: 24),
              Text('Warna', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final palette in brandPalettes)
                    ChoiceChip(
                      selected: palette == _palette,
                      onSelected: (_) => setState(() => _palette = palette),
                      avatar: _Swatch(palette: palette),
                      label: Text(palette.name),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Logo', style: Theme.of(context).textTheme.labelLarge),
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
              const SizedBox(height: 16),
              Text(
                'Prototipe: pengaturan ini belum disimpan permanen. Di versi penuh, '
                'tiap organisasi menyimpan identitasnya sendiri di server.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            ref.read(brandingProvider.notifier).update(_draft);
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
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
