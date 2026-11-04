/// Tempat menyimpan file data mode offline. Implementasi file ada di `offline_files_io.dart`.
abstract interface class OfflineStorage {
  /// Isi file data, atau null bila belum pernah disimpan.
  Future<String?> read();

  /// Isi salinan sebelumnya (dipakai bila file utama rusak), atau null.
  Future<String?> readPrevious();

  /// Menyimpan seluruh isi secara utuh: file lama baru diganti setelah file baru selesai ditulis.
  Future<void> write(String contents);
}

/// Penyimpanan di memori, untuk tes.
class MemoryOfflineStorage implements OfflineStorage {
  MemoryOfflineStorage([this.contents]);

  String? contents;
  String? previous;
  var writes = 0;

  @override
  Future<String?> read() async => contents;

  @override
  Future<String?> readPrevious() async => previous;

  @override
  Future<void> write(String value) async {
    previous = contents;
    contents = value;
    writes++;
  }
}
