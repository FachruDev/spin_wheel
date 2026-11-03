import 'package:flutter/material.dart';

/// Meminta satu isian teks. Mengembalikan null bila dibatalkan.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
  String confirmLabel = 'Simpan',
  String? hint,
  bool required = true,
}) => showDialog<String>(
  context: context,
  builder: (_) => _TextPromptDialog(
    title: title,
    label: label,
    initial: initial,
    confirmLabel: confirmLabel,
    hint: hint,
    required: required,
  ),
);

/// Controller dimiliki State dialog, jadi baru dibuang setelah animasi tutup selesai.
class _TextPromptDialog extends StatefulWidget {
  const _TextPromptDialog({
    required this.title,
    required this.label,
    required this.initial,
    required this.confirmLabel,
    required this.hint,
    required this.required,
  });

  final String title;
  final String label;
  final String initial;
  final String confirmLabel;
  final String? hint;
  final bool required;

  @override
  State<_TextPromptDialog> createState() => _TextPromptDialogState();
}

class _TextPromptDialogState extends State<_TextPromptDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !widget.required || _controller.text.trim().isNotEmpty;
    void submit() => Navigator.pop(context, _controller.text.trim());
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(labelText: widget.label, helperText: widget.hint),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => canSubmit ? submit() : null,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: canSubmit ? submit : null, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// Konfirmasi ya/tidak. Mengembalikan true bila pengguna menyetujui.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error) : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Alasan hangus; dipakai di panel operator dan daftar pemenang.
Future<String?> askForfeitReason(BuildContext context, String name) => askText(
  context,
  title: 'Tandai $name hangus?',
  label: 'Alasan',
  initial: 'Tidak hadir saat dipanggil',
  confirmLabel: 'Tandai hangus',
  hint: 'Unit hadiah kembali ke stok dan bisa langsung diundi ulang.',
);
