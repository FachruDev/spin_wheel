import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/ui/async_view.dart';
import 'winner_report.dart';
import 'winners_excel.dart';
import 'winners_pdf.dart';

const _xlsxMime = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

/// Tombol "Export Excel" dan menu "Export PDF" untuk laporan pemenang.
class WinnerExportButtons extends StatefulWidget {
  const WinnerExportButtons({super.key, required this.report});

  final WinnerReport Function() report;

  @override
  State<WinnerExportButtons> createState() => _WinnerExportButtonsState();
}

class _WinnerExportButtonsState extends State<WinnerExportButtons> {
  var _busy = false;

  Future<void> _save(String fileName, String mimeType, Future<List<int>> Function(WinnerReport) build) async {
    setState(() => _busy = true);
    try {
      final bytes = await build(widget.report());
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Simpan $fileName',
        fileName: fileName,
        bytes: Uint8List.fromList(bytes),
        mimeType: mimeType,
      );
      if (saved != null && mounted) showInfoSnack(context, '$fileName tersimpan.');
    } catch (e) {
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.tonalIcon(
          onPressed: _busy
              ? null
              : () => _save(
                  widget.report().fileName('pemenang', 'xlsx'),
                  _xlsxMime,
                  (r) async => buildWinnersWorkbook(r),
                ),
          icon: const Icon(Icons.table_view_rounded),
          label: const Text('Export Excel'),
        ),
        MenuAnchor(
          menuChildren: [
            for (final kind in WinnerPdfKind.values)
              MenuItemButton(
                leadingIcon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => _save(
                  widget.report().fileName(kind.filePrefix, 'pdf'),
                  'application/pdf',
                  (r) => buildWinnersPdf(r, kind),
                ),
                child: Text(kind.label),
              ),
          ],
          builder: (context, controller, _) => FilledButton.tonalIcon(
            onPressed: _busy ? null : () => controller.isOpen ? controller.close() : controller.open(),
            icon: _busy
                ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('Export PDF'),
          ),
        ),
      ],
    );
  }
}
