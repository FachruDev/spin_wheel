import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'offline_files_api.dart';
import 'offline_storage.dart';

OfflineFiles? createOfflineFiles() => IoOfflineFiles();

/// File mode offline di folder data aplikasi (Windows: %APPDATA%\Undian\Undian):
///   offline\data.json            data mode offline (+ data.json.bak, versi sebelumnya)
///   Salinan otomatis\*.undian    salinan acara dari server, diperbarui otomatis
class IoOfflineFiles implements OfflineFiles {
  IoOfflineFiles({Future<Directory> Function()? baseDirectory})
    : _baseDirectory = baseDirectory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _baseDirectory;

  static String get _sep => Platform.pathSeparator;

  Future<Directory> _folder(String name) async {
    final base = await _baseDirectory();
    return Directory('${base.path}$_sep$name').create(recursive: true);
  }

  @override
  String get deviceName => Platform.localHostname;

  @override
  Future<OfflineStorage> openStorage() async {
    final folder = await _folder('offline');
    return FileOfflineStorage(File('${folder.path}${_sep}data.json'));
  }

  @override
  Future<String> backupFolder() async => (await _folder('Salinan otomatis')).path;

  @override
  Future<void> writeBackup(String fileName, List<int> bytes) async {
    final folder = await _folder('Salinan otomatis');
    await writeFileSafely(File('${folder.path}$_sep$fileName'), bytes);
  }

  @override
  Future<List<BackupFile>> listBackups() async {
    final folder = await _folder('Salinan otomatis');
    final files = [
      await for (final entity in folder.list())
        if (entity is File && entity.path.toLowerCase().endsWith('.undian'))
          BackupFile(path: entity.path, name: entity.uri.pathSegments.last, modified: (await entity.stat()).modified),
    ];
    return files..sort((a, b) => b.modified.compareTo(a.modified));
  }

  @override
  Future<List<int>> readFile(String path) => File(path).readAsBytes();
}

/// Data offline dalam satu file. Versi sebelumnya disimpan sebagai `.bak`.
class FileOfflineStorage implements OfflineStorage {
  FileOfflineStorage(this.file);

  final File file;

  File get _previous => File('${file.path}.bak');

  @override
  Future<String?> read() async => await file.exists() ? file.readAsString() : null;

  @override
  Future<String?> readPrevious() async => await _previous.exists() ? _previous.readAsString() : null;

  @override
  Future<void> write(String contents) async {
    if (await file.exists()) await file.copy(_previous.path);
    await writeFileSafely(file, utf8.encode(contents));
  }
}

/// Menulis ke file sementara lalu menggantikan [file], supaya file tidak pernah setengah jadi
/// bila aplikasi tertutup atau laptop mati saat menyimpan.
Future<void> writeFileSafely(File file, List<int> bytes) async {
  final temp = File('${file.path}.tmp');
  await temp.writeAsBytes(bytes, flush: true);
  await temp.rename(file.path);
}
