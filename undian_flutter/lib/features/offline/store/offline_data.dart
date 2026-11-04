import 'dart:math';

import 'package:undian_client/undian_client.dart';

/// Seluruh data mode offline di satu laptop. Disimpan sebagai satu file JSON.
///
/// Model data sama dengan server (undian_client), jadi halaman aplikasi bisa memakainya tanpa
/// perubahan. id dibuat sendiri oleh laptop ini dan tidak ada hubungannya dengan id server.
class OfflineData {
  OfflineData({
    required this.deviceId,
    this.nextId = 1,
    List<Organization>? organizations,
    List<DrawEvent>? events,
    Map<int, OfflineEventInfo>? eventInfo,
    List<EventParticipant>? participants,
    List<EventPrize>? prizes,
    List<PrizeWinner>? winners,
  }) : organizations = organizations ?? [],
       events = events ?? [],
       eventInfo = eventInfo ?? {},
       participants = participants ?? [],
       prizes = prizes ?? [],
       winners = winners ?? [];

  factory OfflineData.empty() => OfflineData(deviceId: randomUuid());

  static const format = 'undian-data-offline';
  static const version = 1;

  /// Penanda laptop ini; dicatat sebagai "drawnBy" pada pemenang yang diundi offline.
  final String deviceId;
  int nextId;
  final List<Organization> organizations;
  final List<DrawEvent> events;

  /// Keterangan tiap acara (asal data), per id acara.
  final Map<int, OfflineEventInfo> eventInfo;
  final List<EventParticipant> participants;
  final List<EventPrize> prizes;
  final List<PrizeWinner> winners;

  int takeId() => nextId++;

  Map<String, dynamic> toJson() => {
    'format': format,
    'version': version,
    'deviceId': deviceId,
    'nextId': nextId,
    'organizations': [for (final o in organizations) o.toJson()],
    'events': [for (final e in events) e.toJson()],
    'eventInfo': [
      for (final MapEntry(:key, :value) in eventInfo.entries) {'eventId': key, ...value.toJson()},
    ],
    'participants': [for (final p in participants) p.toJson()],
    'prizes': [for (final p in prizes) p.toJson()],
    'winners': [for (final w in winners) w.toJson()],
  };

  /// Melempar [FormatException] bila isi file bukan data offline Undian.
  factory OfflineData.fromJson(Map<String, dynamic> json) {
    if (json['format'] != format) throw const FormatException('Bukan file data offline Undian');
    if ((json['version'] as int) > version) {
      throw const FormatException('Data offline dibuat oleh versi aplikasi yang lebih baru');
    }
    List<Map<String, dynamic>> list(String key) => [
      for (final item in json[key] as List) (item as Map).cast<String, dynamic>(),
    ];
    return OfflineData(
      deviceId: json['deviceId'] as String,
      nextId: json['nextId'] as int,
      organizations: [for (final j in list('organizations')) Organization.fromJson(j)],
      events: [for (final j in list('events')) DrawEvent.fromJson(j)],
      eventInfo: {for (final j in list('eventInfo')) j['eventId'] as int: OfflineEventInfo.fromJson(j)},
      participants: [for (final j in list('participants')) EventParticipant.fromJson(j)],
      prizes: [for (final j in list('prizes')) EventPrize.fromJson(j)],
      winners: [for (final j in list('winners')) PrizeWinner.fromJson(j)],
    );
  }
}

/// Asal dan riwayat satu acara di mode offline.
class OfflineEventInfo {
  const OfflineEventInfo({
    required this.lineageId,
    required this.origin,
    required this.changedAt,
    this.source,
    this.importedAt,
    this.exportedAt,
  });

  /// Sama untuk semua salinan acara yang sama (di server, laptop A, laptop B), sehingga paket
  /// yang diimpor ulang bisa mengganti salinan lamanya.
  final String lineageId;

  /// Keterangan untuk pengguna, mis. "Paket dari LAPTOP-A · mode offline".
  final String origin;

  /// Acara asal di server, bila data ini berasal dari server.
  final PackageSource? source;
  final DateTime? importedAt;
  final DateTime changedAt;
  final DateTime? exportedAt;

  OfflineEventInfo copyWith({DateTime? changedAt, DateTime? exportedAt}) => OfflineEventInfo(
    lineageId: lineageId,
    origin: origin,
    source: source,
    importedAt: importedAt,
    changedAt: changedAt ?? this.changedAt,
    exportedAt: exportedAt ?? this.exportedAt,
  );

  Map<String, dynamic> toJson() => {
    'lineageId': lineageId,
    'origin': origin,
    if (source != null) 'source': source!.toJson(),
    if (importedAt != null) 'importedAt': importedAt!.toUtc().toIso8601String(),
    'changedAt': changedAt.toUtc().toIso8601String(),
    if (exportedAt != null) 'exportedAt': exportedAt!.toUtc().toIso8601String(),
  };

  factory OfflineEventInfo.fromJson(Map<String, dynamic> json) => OfflineEventInfo(
    lineageId: json['lineageId'] as String,
    origin: json['origin'] as String,
    source: json['source'] == null ? null : PackageSource.fromJson((json['source'] as Map).cast<String, dynamic>()),
    importedAt: _date(json['importedAt']),
    changedAt: _date(json['changedAt'])!,
    exportedAt: _date(json['exportedAt']),
  );
}

/// Acara asal di server: alamat server dan id-nya di sana.
class PackageSource {
  const PackageSource({required this.serverUrl, required this.organizationId, required this.eventId});

  final String serverUrl;
  final int organizationId;
  final int eventId;

  /// Penanda garis keturunan acara server, lihat [OfflineEventInfo.lineageId].
  String get lineageId => 'server:$serverUrl#$eventId';

  Map<String, dynamic> toJson() => {'serverUrl': serverUrl, 'organizationId': organizationId, 'eventId': eventId};

  factory PackageSource.fromJson(Map<String, dynamic> json) => PackageSource(
    serverUrl: json['serverUrl'] as String,
    organizationId: json['organizationId'] as int,
    eventId: json['eventId'] as int,
  );
}

DateTime? _date(Object? value) => value == null ? null : DateTime.parse(value as String);

/// UUID versi 4 acak (tanpa dependency tambahan).
String randomUuid() {
  final random = Random.secure();
  final bytes = [for (var i = 0; i < 16; i++) random.nextInt(256)];
  bytes[6] = (bytes[6] & 0x0F) | 0x40;
  bytes[8] = (bytes[8] & 0x3F) | 0x80;
  final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')].join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-${hex.substring(20)}';
}
