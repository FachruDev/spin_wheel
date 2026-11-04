import 'dart:convert';
import 'dart:typed_data';

import 'package:undian_client/undian_client.dart';
import 'package:undian_core/undian_core.dart' as core;

import '../../../core/data/undian_repository.dart';
import '../../../core/server/core_mapping.dart';
import '../package/event_package.dart';
import 'offline_data.dart';
import 'offline_storage.dart';

/// Data acara yang disimpan di laptop ini (mode offline).
///
/// Aturannya sama dengan server (`undian_core`): kelayakan, stok, undian berbobot poin, import
/// peserta, hadiah, dan status pemenang. Setiap perubahan langsung disimpan ke [OfflineStorage].
class OfflineRepository implements UndianRepository {
  OfflineRepository._(this._storage, this._data, this._engine, this._now);

  /// Membuka data dari [storage]. Bila file utama rusak, salinan sebelumnya yang dipakai.
  static Future<OfflineRepository> open(
    OfflineStorage storage, {
    core.DrawEngine? engine,
    DateTime Function()? clock,
  }) async {
    final data = _parse(await storage.read()) ?? _parse(await storage.readPrevious()) ?? OfflineData.empty();
    return OfflineRepository._(storage, data, engine ?? core.DrawEngine(), clock ?? DateTime.now);
  }

  static OfflineData? _parse(String? text) {
    if (text == null) return null;
    try {
      return OfflineData.fromJson((jsonDecode(text) as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  final OfflineStorage _storage;
  final OfflineData _data;
  final core.DrawEngine _engine;
  final DateTime Function() _now;
  Future<void> _saving = Future.value();

  DateTime get _utcNow => _now().toUtc();

  @override
  bool get isOffline => true;

  /// Menyimpan seluruh data. Penulisan berjalan berurutan, jadi file selalu berisi versi terakhir.
  Future<void> _save() {
    final contents = jsonEncode(_data.toJson());
    return _saving = _saving.then((_) => _storage.write(contents));
  }

  /// Mencatat waktu perubahan acara lalu menyimpan.
  Future<void> _touch(int eventId) {
    final info = _data.eventInfo[eventId];
    if (info != null) _data.eventInfo[eventId] = info.copyWith(changedAt: _utcNow);
    return _save();
  }

  static UndianException _notFound() => UndianException(message: 'Data tidak ditemukan di laptop ini.');

  static void _ensure(String? problem) {
    if (problem != null) throw UndianException(message: problem);
  }

  Organization _organization(int id) =>
      _data.organizations.firstWhere((o) => o.id == id, orElse: () => throw _notFound());

  DrawEvent _event(int id) => _data.events.firstWhere((e) => e.id == id, orElse: () => throw _notFound());

  void _replace<T>(List<T> list, bool Function(T) test, T value) => list[list.indexWhere(test)] = value;

  // --- Organisasi ------------------------------------------------------------------------------

  @override
  Future<List<MyOrganization>> myOrganizations() async => [
    for (final o in List.of(_data.organizations)..sort((a, b) => a.name.compareTo(b.name)))
      MyOrganization(organization: o, role: MemberRole.admin),
  ];

  @override
  Future<MyOrganization> createOrganization(String name) async {
    final trimmed = name.trim();
    _ensure(core.UndianRules.nameProblem(trimmed, 'organisasi'));
    final organization = Organization(
      id: _data.takeId(),
      name: trimmed,
      primaryColor: core.UndianRules.defaultPrimaryColor,
      accentColor: core.UndianRules.defaultAccentColor,
      createdAt: _utcNow,
    );
    _data.organizations.add(organization);
    await _save();
    return MyOrganization(organization: organization, role: MemberRole.admin);
  }

  @override
  Future<Organization> updateBranding(
    int organizationId, {
    required String name,
    required int primaryColor,
    required int accentColor,
    ByteData? logo,
  }) async {
    final trimmed = name.trim();
    _ensure(core.UndianRules.nameProblem(trimmed, 'organisasi'));
    _ensure(core.UndianRules.logoProblem(logo?.lengthInBytes));
    final updated = _organization(
      organizationId,
    ).copyWith(name: trimmed, primaryColor: primaryColor, accentColor: accentColor, logo: logo);
    _replace(_data.organizations, (o) => o.id == organizationId, updated);
    await _save();
    return updated;
  }

  // --- Acara -----------------------------------------------------------------------------------

  @override
  Future<List<DrawEvent>> events(int organizationId) async {
    _organization(organizationId);
    return _data.events.where((e) => e.organizationId == organizationId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<DrawEvent> createEvent(
    int organizationId, {
    required String name,
    DateTime? eventDate,
    required bool allowMultipleWins,
  }) async {
    _organization(organizationId);
    final trimmed = name.trim();
    _ensure(core.UndianRules.nameProblem(trimmed, 'acara'));
    final event = DrawEvent(
      id: _data.takeId(),
      organizationId: organizationId,
      name: trimmed,
      eventDate: eventDate,
      allowMultipleWins: allowMultipleWins,
      createdAt: _utcNow,
    );
    _data.events.add(event);
    _data.eventInfo[event.id!] = OfflineEventInfo(
      lineageId: 'offline:${randomUuid()}',
      origin: 'Dibuat di mode offline',
      changedAt: _utcNow,
    );
    await _save();
    return event;
  }

  @override
  Future<DrawEvent> updateEvent(
    int eventId, {
    required String name,
    DateTime? eventDate,
    required bool allowMultipleWins,
  }) async {
    final trimmed = name.trim();
    _ensure(core.UndianRules.nameProblem(trimmed, 'acara'));
    final updated = _event(eventId).copyWith(name: trimmed, eventDate: eventDate, allowMultipleWins: allowMultipleWins);
    _replace(_data.events, (e) => e.id == eventId, updated);
    await _touch(eventId);
    return updated;
  }

  /// Keterangan asal acara di laptop ini.
  OfflineEventInfo? eventInfo(int eventId) => _data.eventInfo[eventId];

  /// Menghapus acara beserta peserta, hadiah, dan pemenangnya dari laptop ini.
  Future<void> deleteEvent(int eventId) async {
    _event(eventId);
    _removeEventData(eventId);
    await _save();
  }

  void _removeEventData(int eventId) {
    _data.events.removeWhere((e) => e.id == eventId);
    _data.eventInfo.remove(eventId);
    _data.participants.removeWhere((p) => p.eventId == eventId);
    _data.prizes.removeWhere((p) => p.eventId == eventId);
    _data.winners.removeWhere((w) => w.eventId == eventId);
  }

  // --- Peserta ---------------------------------------------------------------------------------

  @override
  Future<List<EventParticipant>> participants(int eventId) async {
    _event(eventId);
    return _data.participants.where((p) => p.eventId == eventId).toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<ImportResult> importParticipants(int eventId, List<ParticipantInput> rows, {required bool replaceAll}) async {
    _event(eventId);
    final plan = core.UndianRules.planImport([for (final r in rows) _toImportRow(r)]);
    if (replaceAll && _data.winners.any((w) => w.eventId == eventId)) {
      throw UndianException(message: core.UndianRules.replaceAllWithWinnersMessage);
    }
    if (replaceAll) {
      _data.participants.removeWhere((p) => p.eventId == eventId && !plan.valid.containsKey(p.nik));
    }
    var inserted = 0, updated = 0;
    for (final MapEntry(key: nik, value: row) in plan.valid.entries) {
      final index = _data.participants.indexWhere((p) => p.eventId == eventId && p.nik == nik);
      final id = index < 0 ? _data.takeId() : _data.participants[index].id!;
      final participant = _participantFrom(id, eventId, row);
      if (index < 0) {
        _data.participants.add(participant);
        inserted++;
      } else {
        _data.participants[index] = participant;
        updated++;
      }
    }
    await _touch(eventId);
    return ImportResult(inserted: inserted, updated: updated, rejected: plan.rejected);
  }

  @override
  Future<EventParticipant> addParticipant(int eventId, ParticipantInput input) async {
    _event(eventId);
    final row = _toImportRow(input).cleaned();
    _ensure(core.UndianRules.participantProblem(row));
    _ensureNikFree(eventId, row.nik);
    final participant = _participantFrom(_data.takeId(), eventId, row);
    _data.participants.add(participant);
    await _touch(eventId);
    return participant;
  }

  @override
  Future<EventParticipant> updateParticipant(EventParticipant participant, ParticipantInput input) async {
    final existing = _participant(participant.id);
    final row = _toImportRow(input).cleaned();
    _ensure(core.UndianRules.participantProblem(row));
    if (row.nik != existing.nik) _ensureNikFree(existing.eventId, row.nik);
    final updated = _participantFrom(existing.id!, existing.eventId, row);
    _replace(_data.participants, (p) => p.id == existing.id, updated);
    await _touch(existing.eventId);
    return updated;
  }

  @override
  Future<void> deleteParticipant(EventParticipant participant) async {
    final existing = _participant(participant.id);
    if (_data.winners.any((w) => w.participantId == existing.id)) {
      throw UndianException(message: core.UndianRules.deleteDrawnParticipantMessage);
    }
    _data.participants.removeWhere((p) => p.id == existing.id);
    await _touch(existing.eventId);
  }

  EventParticipant _participant(int? id) =>
      _data.participants.firstWhere((p) => p.id == id, orElse: () => throw _notFound());

  void _ensureNikFree(int eventId, String nik) {
    if (_data.participants.any((p) => p.eventId == eventId && p.nik == nik)) {
      throw UndianException(message: core.UndianRules.duplicateNikMessage(nik));
    }
  }

  static core.ImportRow _toImportRow(ParticipantInput r) => core.ImportRow(
    nik: r.nik,
    name: r.name,
    area: r.area,
    department: r.department,
    employmentStatus: r.employmentStatus,
    phone: r.phone,
    points: r.points,
    groups: r.groups,
  );

  static EventParticipant _participantFrom(int id, int eventId, core.ImportRow row) => EventParticipant(
    id: id,
    eventId: eventId,
    nik: row.nik,
    name: row.name,
    area: row.area,
    department: row.department,
    employmentStatus: row.employmentStatus,
    phone: row.phone,
    points: row.points,
    groups: row.groups,
  );

  // --- Hadiah ----------------------------------------------------------------------------------

  @override
  Future<List<EventPrize>> prizes(int eventId) async {
    _event(eventId);
    return _data.prizes.where((p) => p.eventId == eventId).toList()
      ..sort((a, b) => a.sortOrder != b.sortOrder ? a.sortOrder.compareTo(b.sortOrder) : a.id!.compareTo(b.id!));
  }

  @override
  Future<EventPrize> savePrize(EventPrize prize) async {
    final name = prize.name.trim();
    final groups = core.UndianRules.cleanGroups(prize.eligibleGroups);
    _ensure(
      core.UndianRules.prizeProblem(name: name, quantity: prize.quantity, openToAll: prize.openToAll, groups: groups),
    );
    final id = prize.id;
    if (id == null) {
      _event(prize.eventId);
      final saved = prize.copyWith(id: _data.takeId(), name: name, eligibleGroups: groups);
      _data.prizes.add(saved);
      await _touch(prize.eventId);
      return saved;
    }
    final existing = _data.prizes.where((p) => p.id == id && p.eventId == prize.eventId);
    if (existing.isEmpty) throw _notFound();
    final used = _data.winners.where((w) => w.prizeId == id && w.status.usesStock).length;
    _ensure(core.UndianRules.prizeQuantityProblem(quantity: prize.quantity, used: used));
    final saved = prize.copyWith(name: name, eligibleGroups: groups);
    _replace(_data.prizes, (p) => p.id == id, saved);
    await _touch(prize.eventId);
    return saved;
  }

  @override
  Future<void> deletePrize(EventPrize prize) async {
    final existing = _data.prizes.firstWhere((p) => p.id == prize.id, orElse: () => throw _notFound());
    if (_data.winners.any((w) => w.prizeId == existing.id)) {
      throw UndianException(message: core.UndianRules.deleteDrawnPrizeMessage);
    }
    _data.prizes.remove(existing);
    await _touch(existing.eventId);
  }

  // --- Undian & pemenang -----------------------------------------------------------------------

  @override
  Future<List<PrizeWinner>> winners(int eventId) async {
    _event(eventId);
    return _data.winners.where((w) => w.eventId == eventId).toList()
      ..sort((a, b) => a.roundNo != b.roundNo ? a.roundNo.compareTo(b.roundNo) : a.id!.compareTo(b.id!));
  }

  @override
  Future<DrawResult> draw(int prizeId, int count) async {
    _ensure(core.UndianRules.drawCountProblem(count));
    final prize = _data.prizes.firstWhere((p) => p.id == prizeId, orElse: () => throw _notFound());
    final event = _event(prize.eventId);
    final participants = _data.participants.where((p) => p.eventId == event.id).toList();
    final winners = _data.winners.where((w) => w.eventId == event.id).toList();

    final coreParticipants = [for (final p in participants) toCoreParticipant(p)];
    final corePrize = toCorePrize(prize);
    final coreWinners = [for (final w in winners) toCoreWinner(w)];
    final pool = core.DrawEngine.eligible(
      participants: coreParticipants,
      prize: corePrize,
      winners: coreWinners,
      allowMultipleWins: event.allowMultipleWins,
    );
    final List<core.Participant> drawn;
    try {
      drawn = _engine.drawForPrize(
        participants: coreParticipants,
        prize: corePrize,
        winners: coreWinners,
        count: count,
        allowMultipleWins: event.allowMultipleWins,
      );
    } on core.DrawException catch (e) {
      throw UndianException(message: e.message);
    }

    final roundNo = core.UndianRules.nextRoundNo(winners.map((w) => w.roundNo));
    final now = _utcNow;
    final drawnBy = UuidValue.fromString(_data.deviceId);
    final records = [
      for (final p in drawn)
        PrizeWinner(
          id: _data.takeId(),
          eventId: event.id!,
          prizeId: prizeId,
          participantId: p.id,
          roundNo: roundNo,
          status: WinnerStatus.sah,
          drawnAt: now,
          drawnBy: drawnBy,
        ),
    ];
    _data.winners.addAll(records);
    await _touch(event.id!);

    final byId = {for (final p in participants) p.id!: p};
    final sample = (List.of(pool)..shuffle()).take(core.UndianRules.poolSampleSize);
    return DrawResult(
      roundNo: roundNo,
      prize: prize,
      winners: [for (final p in drawn) byId[p.id]!],
      winnerRecords: records,
      poolSize: pool.length,
      poolSample: [for (final p in sample) byId[p.id]!],
    );
  }

  @override
  Future<PrizeWinner> setWinnerStatus(int winnerId, WinnerStatus status, String? note) async {
    final winner = _data.winners.firstWhere((w) => w.id == winnerId, orElse: () => throw _notFound());
    final reason = note?.trim();
    _ensure(
      core.UndianRules.statusChangeProblem(
        current: core.WinnerStatus.values.byName(winner.status.name),
        next: core.WinnerStatus.values.byName(status.name),
        note: reason,
      ),
    );
    final updated = winner.copyWith(status: status, note: reason);
    _replace(_data.winners, (w) => w.id == winnerId, updated);
    await _touch(winner.eventId);
    return updated;
  }

  // --- Paket acara -----------------------------------------------------------------------------

  /// Acara di laptop ini yang berasal dari garis keturunan yang sama dengan [lineageId].
  List<DrawEvent> eventsWithLineage(String lineageId) => [
    for (final e in _data.events)
      if (_data.eventInfo[e.id]?.lineageId == lineageId) e,
  ];

  /// Membuat paket dari acara offline [eventId].
  Future<EventPackage> exportPackage(int eventId, {required String exportedFrom}) async {
    final event = _event(eventId);
    final info = _data.eventInfo[eventId];
    final package = await collectEventPackage(
      this,
      organizationId: event.organizationId,
      eventId: eventId,
      lineageId: info?.lineageId ?? 'offline:${randomUuid()}',
      source: info?.source,
      exportedFrom: exportedFrom,
      now: _now(),
    );
    return package;
  }

  /// Mencatat bahwa acara sudah diekspor (ditampilkan di halaman acara).
  Future<void> markExported(int eventId) async {
    final info = _data.eventInfo[eventId];
    if (info == null) return;
    _data.eventInfo[eventId] = info.copyWith(exportedAt: _utcNow);
    await _save();
  }

  /// Menyalin isi [package] ke laptop ini sebagai acara baru dan mengembalikan acara tersebut.
  ///
  /// Dengan [replaceEventId], acara lama itu dihapus lebih dulu (dipakai saat mengimpor versi
  /// terbaru dari acara yang sama). Organisasi dengan nama yang sama dipakai ulang, dan
  /// identitasnya (warna, logo) diperbarui dari paket.
  Future<DrawEvent> importPackage(EventPackage package, {int? replaceEventId, String? origin}) async {
    if (replaceEventId != null) {
      _event(replaceEventId);
      _removeEventData(replaceEventId);
    }
    final source = package.organization;
    final existing = _data.organizations.where((o) => o.name == source.name).firstOrNull;
    final Organization organization;
    if (existing == null) {
      organization = source.copyWith(id: _data.takeId());
      _data.organizations.add(organization);
    } else {
      organization = existing.copyWith(
        primaryColor: source.primaryColor,
        accentColor: source.accentColor,
        logo: source.logo,
      );
      _replace(_data.organizations, (o) => o.id == existing.id, organization);
    }

    final event = package.event.copyWith(id: _data.takeId(), organizationId: organization.id!);
    _data.events.add(event);
    final participantIds = <int, int>{};
    for (final p in package.participants) {
      final id = _data.takeId();
      participantIds[p.id!] = id;
      _data.participants.add(p.copyWith(id: id, eventId: event.id!));
    }
    final prizeIds = <int, int>{};
    for (final p in package.prizes) {
      final id = _data.takeId();
      prizeIds[p.id!] = id;
      _data.prizes.add(p.copyWith(id: id, eventId: event.id!));
    }
    for (final w in package.winners) {
      _data.winners.add(
        w.copyWith(
          id: _data.takeId(),
          eventId: event.id!,
          participantId: participantIds[w.participantId]!,
          prizeId: prizeIds[w.prizeId]!,
        ),
      );
    }
    _data.eventInfo[event.id!] = OfflineEventInfo(
      lineageId: package.lineageId,
      origin: origin ?? 'Paket dari ${package.exportedFrom}',
      source: package.source,
      importedAt: _utcNow,
      changedAt: package.exportedAt,
    );
    await _save();
    return event;
  }
}
