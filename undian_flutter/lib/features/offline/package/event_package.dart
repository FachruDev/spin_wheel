import 'dart:convert';

import 'package:undian_client/undian_client.dart';

import '../../../core/data/undian_repository.dart';
import '../../../core/server/core_mapping.dart';
import '../store/offline_data.dart';

/// Paket acara (`.undian`): satu file berisi semua data satu acara (identitas organisasi,
/// acara, peserta, hadiah, pemenang) untuk dipindah ke laptop lain atau dibuka di mode offline.
///
/// Isinya JSON biasa. File ini memuat data pribadi peserta (NIK, nomor HP); perlakukan sebagai
/// dokumen rahasia.
class EventPackage {
  const EventPackage({
    required this.lineageId,
    required this.exportedAt,
    required this.exportedFrom,
    required this.organization,
    required this.event,
    required this.participants,
    required this.prizes,
    required this.winners,
    this.source,
  });

  static const format = 'undian-paket-acara';
  static const version = 1;
  static const fileExtension = 'undian';

  /// Lihat [OfflineEventInfo.lineageId].
  final String lineageId;
  final DateTime exportedAt;

  /// Keterangan asal, mis. "LAPTOP-A · mode offline" atau "LAPTOP-A · server api.contoh.id".
  final String exportedFrom;

  /// Acara asal di server, bila ada.
  final PackageSource? source;
  final Organization organization;
  final DrawEvent event;
  final List<EventParticipant> participants;
  final List<EventPrize> prizes;
  final List<PrizeWinner> winners;

  /// Jumlah pemenang sah yang masih memakai unit hadiah (bukan hangus atau diskualifikasi).
  int get activeWinnerCount => winners.where((w) => w.status.usesStock).length;

  List<int> encode() => utf8.encode(
    jsonEncode({
      'format': format,
      'version': version,
      'lineageId': lineageId,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'exportedFrom': exportedFrom,
      if (source != null) 'source': source!.toJson(),
      'organization': organization.toJson(),
      'event': event.toJson(),
      'participants': [for (final p in participants) p.toJson()],
      'prizes': [for (final p in prizes) p.toJson()],
      'winners': [for (final w in winners) w.toJson()],
    }),
  );

  /// Membaca isi file paket. Melempar [UndianException] dengan pesan untuk pengguna bila file
  /// bukan paket Undian, dibuat versi aplikasi yang lebih baru, atau isinya rusak.
  static EventPackage decode(List<int> bytes) {
    final Object? root;
    try {
      root = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw UndianException(message: 'File ini bukan paket acara Undian, atau isinya rusak.');
    }
    if (root is! Map || root['format'] != format) {
      throw UndianException(message: 'File ini bukan paket acara Undian.');
    }
    final json = root.cast<String, dynamic>();
    if ((json['version'] as num? ?? 0) > version) {
      throw UndianException(message: 'Paket ini dibuat oleh versi aplikasi yang lebih baru. Perbarui aplikasi Undian.');
    }
    final EventPackage package;
    try {
      List<Map<String, dynamic>> list(String key) => [
        for (final item in json[key] as List) (item as Map).cast<String, dynamic>(),
      ];
      Map<String, dynamic> map(String key) => (json[key] as Map).cast<String, dynamic>();
      package = EventPackage(
        lineageId: json['lineageId'] as String,
        exportedAt: DateTime.parse(json['exportedAt'] as String),
        exportedFrom: json['exportedFrom'] as String,
        source: json['source'] == null ? null : PackageSource.fromJson(map('source')),
        organization: Organization.fromJson(map('organization')),
        event: DrawEvent.fromJson(map('event')),
        participants: [for (final j in list('participants')) EventParticipant.fromJson(j)],
        prizes: [for (final j in list('prizes')) EventPrize.fromJson(j)],
        winners: [for (final j in list('winners')) PrizeWinner.fromJson(j)],
      );
    } catch (_) {
      throw UndianException(message: 'Isi paket acara rusak atau tidak lengkap.');
    }
    final problem = package._consistencyProblem();
    if (problem != null) throw UndianException(message: 'Isi paket acara tidak konsisten: $problem.');
    return package;
  }

  /// Memastikan semua data merujuk ke acara ini dan setiap pemenang punya peserta & hadiahnya.
  String? _consistencyProblem() {
    final eventId = event.id;
    if (eventId == null || organization.id == null) return 'id acara/organisasi kosong';
    if (event.organizationId != organization.id) return 'acara bukan milik organisasi di paket';
    final participantIds = <int>{};
    for (final p in participants) {
      if (p.eventId != eventId || p.id == null || !participantIds.add(p.id!)) return 'data peserta';
    }
    final prizeIds = <int>{};
    for (final p in prizes) {
      if (p.eventId != eventId || p.id == null || !prizeIds.add(p.id!)) return 'data hadiah';
    }
    for (final w in winners) {
      if (w.eventId != eventId || !participantIds.contains(w.participantId) || !prizeIds.contains(w.prizeId)) {
        return 'data pemenang';
      }
    }
    return null;
  }
}

/// Mengumpulkan satu acara dari [repository] (server atau offline) menjadi paket.
Future<EventPackage> collectEventPackage(
  UndianRepository repository, {
  required int organizationId,
  required int eventId,
  required String lineageId,
  required String exportedFrom,
  PackageSource? source,
  DateTime? now,
}) async {
  final (organizations, events) = await (repository.myOrganizations(), repository.events(organizationId)).wait;
  final organization = organizations.firstWhere(
    (m) => m.organization.id == organizationId,
    orElse: () => throw UndianException(message: 'Organisasi tidak ditemukan.'),
  );
  final event = events.firstWhere(
    (e) => e.id == eventId,
    orElse: () => throw UndianException(message: 'Acara tidak ditemukan.'),
  );
  final (participants, prizes, winners) = await (
    repository.participants(eventId),
    repository.prizes(eventId),
    repository.winners(eventId),
  ).wait;
  return EventPackage(
    lineageId: lineageId,
    exportedAt: (now ?? DateTime.now()).toUtc(),
    exportedFrom: exportedFrom,
    source: source,
    organization: organization.organization,
    event: event,
    participants: participants,
    prizes: prizes,
    winners: winners,
  );
}
