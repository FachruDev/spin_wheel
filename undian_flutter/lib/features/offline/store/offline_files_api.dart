import 'offline_storage.dart';

/// Akses file untuk mode offline: data offline, salinan otomatis, dan membaca file paket.
/// Hanya ada di aplikasi desktop; di web tidak tersedia.
abstract interface class OfflineFiles {
  /// Nama laptop ini, untuk keterangan asal paket.
  String get deviceName;

  Future<OfflineStorage> openStorage();

  /// Folder salinan otomatis acara dari server.
  Future<String> backupFolder();
  Future<void> writeBackup(String fileName, List<int> bytes);

  /// Salinan otomatis, terbaru lebih dulu.
  Future<List<BackupFile>> listBackups();
  Future<List<int>> readFile(String path);
}

class BackupFile {
  const BackupFile({required this.path, required this.name, required this.modified});

  final String path;
  final String name;
  final DateTime modified;
}
