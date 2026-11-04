import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/data/repository_providers.dart';
import '../../core/server/server_providers.dart';
import 'store/offline_files.dart';
import 'store/offline_repository.dart';

/// Akses file mode offline; null di web (mode offline tidak tersedia).
final offlineFilesProvider = Provider<OfflineFiles?>((ref) => createOfflineFiles());

/// Data offline di laptop ini, dibuka sekali lalu dipakai selama aplikasi berjalan.
final offlineRepositoryProvider = FutureProvider<OfflineRepository>((ref) async {
  final files = ref.watch(offlineFilesProvider);
  if (files == null) throw UndianException(message: 'Mode offline hanya tersedia di aplikasi desktop.');
  return OfflineRepository.open(await files.openStorage());
});

/// True bila aplikasi sedang di mode offline.
final isOfflineProvider = Provider<bool>((ref) => ref.watch(offlineSessionProvider) != null);

/// Penyimpanan offline yang sedang aktif, atau null bila online.
final activeOfflineRepositoryProvider = Provider<OfflineRepository?>(
  (ref) => switch (ref.watch(offlineSessionProvider)) {
    final OfflineRepository repository => repository,
    _ => null,
  },
);

/// Masuk mode offline: semua halaman memakai data di laptop ini, tanpa login dan tanpa server.
Future<void> enterOfflineMode(WidgetRef ref) async {
  final repository = await ref.read(offlineRepositoryProvider.future);
  ref.read(offlineSessionProvider.notifier).enter(repository);
}

void exitOfflineMode(WidgetRef ref) => ref.read(offlineSessionProvider.notifier).exit();

/// Keterangan asal paket yang diekspor dari laptop ini.
String exportedFromLabel(OfflineFiles? files, {required bool offline}) {
  final device = files?.deviceName ?? 'Browser';
  return offline ? '$device · mode offline' : '$device · server ${Uri.parse(serverUrl).host}';
}
