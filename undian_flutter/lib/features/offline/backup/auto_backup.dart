import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/repository_providers.dart';
import '../../../core/data/server_repository.dart';
import '../../../core/server/server_providers.dart';
import '../../../core/ui/format.dart';
import '../offline_providers.dart';
import '../package/event_package.dart';
import '../store/offline_data.dart';

/// Salinan otomatis (aplikasi desktop, mode online): setiap kali acara dibuka atau berubah di
/// server, seluruh datanya disimpan sebagai paket di laptop ini. Bila server bermasalah, salinan
/// ini bisa langsung dibuka di mode offline.
///
/// State: waktu salinan terakhir per id acara server.
class AutoBackup extends Notifier<Map<int, DateTime>> {
  static const delay = Duration(seconds: 2);

  final _timers = <int, Timer>{};

  @override
  Map<int, DateTime> build() {
    final files = ref.watch(offlineFilesProvider);
    if (files == null) return const {};
    final repository = ref.watch(serverRepositoryProvider);
    final subscription = repository.changes.listen((change) => _schedule(repository, change));
    ref.onDispose(() {
      subscription.cancel();
      for (final t in _timers.values) {
        t.cancel();
      }
      _timers.clear();
    });
    return const {};
  }

  /// Perubahan beruntun (mis. beberapa undian cepat) digabung menjadi satu penyimpanan.
  void _schedule(ServerRepository repository, EventChange change) {
    _timers[change.eventId]?.cancel();
    _timers[change.eventId] = Timer(delay, () => _save(repository, change));
  }

  Future<void> _save(ServerRepository repository, EventChange change) async {
    _timers.remove(change.eventId);
    final files = ref.read(offlineFilesProvider);
    if (files == null) return;
    try {
      final source = PackageSource(
        serverUrl: serverUrl,
        organizationId: change.organizationId,
        eventId: change.eventId,
      );
      final package = await collectEventPackage(
        repository,
        organizationId: change.organizationId,
        eventId: change.eventId,
        lineageId: source.lineageId,
        source: source,
        exportedFrom: exportedFromLabel(files, offline: false),
      );
      await files.writeBackup(backupFileName(package), package.encode());
      state = {...state, change.eventId: DateTime.now()};
    } catch (e) {
      // Salinan otomatis tidak boleh mengganggu pemakaian; dicoba lagi pada perubahan berikutnya.
      debugPrint('Salinan otomatis acara ${change.eventId} gagal: $e');
    }
  }
}

final autoBackupProvider = NotifierProvider<AutoBackup, Map<int, DateTime>>(AutoBackup.new);

/// Satu file per acara server; salinan berikutnya menimpa yang lama.
String backupFileName(EventPackage package) =>
    '${fileSlug(package.organization.name)}_${fileSlug(package.event.name)}_${package.source?.eventId ?? 0}.undian';
