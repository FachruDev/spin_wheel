import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../server/server_providers.dart';
import 'server_repository.dart';
import 'undian_repository.dart';

/// Mode offline yang sedang aktif: berisi penyimpanan lokal, atau null bila aplikasi online.
class OfflineSession extends Notifier<UndianRepository?> {
  @override
  UndianRepository? build() => null;

  void enter(UndianRepository repository) => state = repository;
  void exit() => state = null;
}

final offlineSessionProvider = NotifierProvider<OfflineSession, UndianRepository?>(OfflineSession.new);

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final repository = ServerRepository(ref.watch(clientProvider));
  ref.onDispose(repository.dispose);
  return repository;
});

/// Sumber data yang dipakai semua halaman: penyimpanan lokal di mode offline, server bila online.
final repositoryProvider = Provider<UndianRepository>(
  (ref) => ref.watch(offlineSessionProvider) ?? ref.watch(serverRepositoryProvider),
);
