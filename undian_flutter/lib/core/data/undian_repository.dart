import 'dart:typed_data';

import 'package:undian_client/undian_client.dart';

/// Semua akses data aplikasi. Halaman tidak tahu apakah datanya dari server atau dari file di
/// laptop (mode offline); keduanya memakai model dan aturan yang sama.
///
/// Kesalahan yang ditujukan ke pengguna dilempar sebagai [UndianException].
abstract interface class UndianRepository {
  /// True bila data disimpan di laptop ini (mode offline).
  bool get isOffline;

  Future<List<MyOrganization>> myOrganizations();
  Future<MyOrganization> createOrganization(String name);
  Future<Organization> updateBranding(
    int organizationId, {
    required String name,
    required int primaryColor,
    required int accentColor,
    ByteData? logo,
  });

  Future<List<DrawEvent>> events(int organizationId);
  Future<DrawEvent> createEvent(
    int organizationId, {
    required String name,
    DateTime? eventDate,
    required bool allowMultipleWins,
  });

  Future<List<EventParticipant>> participants(int eventId);
  Future<ImportResult> importParticipants(int eventId, List<ParticipantInput> rows, {required bool replaceAll});

  Future<List<EventPrize>> prizes(int eventId);

  /// Menambah hadiah (id kosong) atau memperbarui yang sudah ada.
  Future<EventPrize> savePrize(EventPrize prize);
  Future<void> deletePrize(EventPrize prize);

  Future<List<PrizeWinner>> winners(int eventId);
  Future<DrawResult> draw(int prizeId, int count);
  Future<PrizeWinner> setWinnerStatus(int winnerId, WinnerStatus status, String? note);
}
