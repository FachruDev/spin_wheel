import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:undian_client/undian_client.dart';
import 'package:undian_flutter/features/offline/store/offline_files_io.dart';
import 'package:undian_flutter/features/offline/store/offline_repository.dart';

void main() {
  late Directory temp;

  setUp(() async => temp = await Directory.systemTemp.createTemp('undian_offline_test'));
  tearDown(() async => temp.delete(recursive: true));

  test('data offline ditulis ke file, menimpa versi lama, dan menyimpan salinan .bak', () async {
    final files = IoOfflineFiles(baseDirectory: () async => temp);
    final repo = await OfflineRepository.open(await files.openStorage());
    await repo.createOrganization('PT Satu');
    await repo.createOrganization('PT Dua'); // penulisan kedua: mengganti file yang sudah ada

    final data = File('${temp.path}${Platform.pathSeparator}offline${Platform.pathSeparator}data.json');
    expect(data.existsSync(), isTrue);
    expect(File('${data.path}.bak').existsSync(), isTrue);
    expect(File('${data.path}.tmp').existsSync(), isFalse);

    final reopened = await OfflineRepository.open(await files.openStorage());
    expect((await reopened.myOrganizations()).map((m) => m.organization.name), ['PT Dua', 'PT Satu']);
  });

  test('salinan otomatis: satu file per acara, terbaru di atas', () async {
    final files = IoOfflineFiles(baseDirectory: () async => temp);
    await files.writeBackup('a.undian', [1]);
    // Waktu file di Windows hanya sampai detik; buat "a" jelas lebih lama.
    File('${await files.backupFolder()}${Platform.pathSeparator}a.undian').setLastModifiedSync(DateTime(2026, 1, 1));
    await files.writeBackup('b.undian', [2]);
    await files.writeBackup('b.undian', [3]); // menimpa
    final backups = await files.listBackups();
    expect(backups.map((b) => b.name), ['b.undian', 'a.undian']);
    expect(await files.readFile(backups.first.path), [3]);
  });

  test('nama organisasi kosong ditolak tanpa mengubah file', () async {
    final files = IoOfflineFiles(baseDirectory: () async => temp);
    final repo = await OfflineRepository.open(await files.openStorage());
    expect(() => repo.createOrganization('  '), throwsA(isA<UndianException>()));
  });
}
