import 'dart:async';
import 'dart:typed_data';

import 'package:undian_client/undian_client.dart';

import 'undian_repository.dart';

/// Data di server Serverpod.
///
/// Setiap perubahan pada sebuah acara diumumkan lewat [changes], dipakai untuk menyimpan
/// salinan otomatis acara di laptop.
class ServerRepository implements UndianRepository {
  ServerRepository(this.client);

  final Client client;
  final _changes = StreamController<EventChange>.broadcast();

  /// Organisasi tiap acara yang pernah dimuat, untuk melengkapi [EventChange].
  final _organizationOfEvent = <int, int>{};

  /// Acara yang dibuka atau diubah. Hanya penulisan dan [notifyOpened] yang memicu ini, bukan
  /// pembacaan biasa.
  Stream<EventChange> get changes => _changes.stream;

  /// Dipanggil saat halaman acara dibuka, supaya salinan di laptop ikut diperbarui.
  void notifyOpened(int organizationId, int eventId) {
    _organizationOfEvent[eventId] = organizationId;
    _emit(eventId);
  }

  void _emit(int eventId) {
    final organizationId = _organizationOfEvent[eventId];
    if (organizationId != null) _changes.add((organizationId: organizationId, eventId: eventId));
  }

  void dispose() => _changes.close();

  @override
  bool get isOffline => false;

  @override
  Future<List<MyOrganization>> myOrganizations() => client.organization.mine();

  @override
  Future<MyOrganization> createOrganization(String name) => client.organization.create(name);

  @override
  Future<Organization> updateBranding(
    int organizationId, {
    required String name,
    required int primaryColor,
    required int accentColor,
    ByteData? logo,
  }) => client.organization.updateBranding(organizationId, name, primaryColor, accentColor, logo);

  @override
  Future<List<DrawEvent>> events(int organizationId) async {
    final list = await client.event.list(organizationId);
    for (final e in list) {
      _organizationOfEvent[e.id!] = organizationId;
    }
    return list;
  }

  @override
  Future<DrawEvent> createEvent(
    int organizationId, {
    required String name,
    DateTime? eventDate,
    required bool allowMultipleWins,
  }) async {
    final event = await client.event.create(organizationId, name, eventDate, allowMultipleWins);
    _organizationOfEvent[event.id!] = organizationId;
    return event;
  }

  @override
  Future<List<EventParticipant>> participants(int eventId) => client.participant.list(eventId);

  @override
  Future<ImportResult> importParticipants(int eventId, List<ParticipantInput> rows, {required bool replaceAll}) async {
    final result = await client.participant.importRows(eventId, rows, replaceAll);
    _emit(eventId);
    return result;
  }

  @override
  Future<List<EventPrize>> prizes(int eventId) => client.prize.list(eventId);

  @override
  Future<EventPrize> savePrize(EventPrize prize) async {
    final saved = await client.prize.save(prize);
    _emit(saved.eventId);
    return saved;
  }

  @override
  Future<void> deletePrize(EventPrize prize) async {
    await client.prize.delete(prize.id!);
    _emit(prize.eventId);
  }

  @override
  Future<List<PrizeWinner>> winners(int eventId) => client.draw.winners(eventId);

  @override
  Future<DrawResult> draw(int prizeId, int count) async {
    final result = await client.draw.draw(prizeId, count);
    _emit(result.prize.eventId);
    return result;
  }

  @override
  Future<PrizeWinner> setWinnerStatus(int winnerId, WinnerStatus status, String? note) async {
    final updated = await client.draw.setStatus(winnerId, status, note);
    _emit(updated.eventId);
    return updated;
  }
}

/// Acara yang berubah di server.
typedef EventChange = ({int organizationId, int eventId});
