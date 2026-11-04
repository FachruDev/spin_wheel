import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repository_providers.dart';
import '../../../core/server/server_providers.dart';
import '../../../core/ui/async_view.dart';
import '../../../core/ui/format.dart';
import '../offline_providers.dart';
import '../package/event_package.dart';
import '../store/offline_data.dart';

/// Menyimpan satu acara sebagai file paket `.undian`, dari server (online) atau dari data di
/// laptop ini (offline). File ini yang dibawa ke laptop lain lalu diimpor di mode offline.
Future<void> exportEventPackage(
  BuildContext context,
  WidgetRef ref, {
  required int organizationId,
  required int eventId,
}) async {
  try {
    final files = ref.read(offlineFilesProvider);
    final offline = ref.read(activeOfflineRepositoryProvider);
    final EventPackage package;
    if (offline != null) {
      package = await offline.exportPackage(eventId, exportedFrom: exportedFromLabel(files, offline: true));
    } else {
      final source = PackageSource(serverUrl: serverUrl, organizationId: organizationId, eventId: eventId);
      package = await collectEventPackage(
        ref.read(repositoryProvider),
        organizationId: organizationId,
        eventId: eventId,
        lineageId: source.lineageId,
        source: source,
        exportedFrom: exportedFromLabel(files, offline: false),
      );
    }
    final fileName = packageFileName(package);
    final saved = await FilePicker.saveFile(
      dialogTitle: 'Simpan paket acara',
      fileName: fileName,
      bytes: Uint8List.fromList(package.encode()),
      mimeType: 'application/json',
    );
    if (saved == null) return;
    await offline?.markExported(eventId);
    if (context.mounted) {
      showInfoSnack(
        context,
        'Paket $fileName tersimpan: ${package.participants.length} peserta, '
        '${package.activeWinnerCount} pemenang. Berisi data pribadi peserta; simpan dengan aman.',
      );
    }
  } catch (e) {
    if (context.mounted) showErrorSnack(context, e);
  }
}

/// Nama file paket, mis. `pt_maju_hut_2026_20261104-1012.undian`.
String packageFileName(EventPackage package) {
  final t = package.exportedAt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final stamp = '${t.year}${two(t.month)}${two(t.day)}-${two(t.hour)}${two(t.minute)}';
  return '${fileSlug(package.organization.name)}_${fileSlug(package.event.name)}_$stamp.${EventPackage.fileExtension}';
}

/// Ringkasan isi paket untuk ditampilkan sebelum diimpor.
String packageSummary(EventPackage package) {
  final units = package.prizes.fold(0, (sum, p) => sum + p.quantity);
  return '${package.participants.length} peserta · ${package.prizes.length} hadiah ($units unit) · '
      '${package.activeWinnerCount} pemenang';
}
