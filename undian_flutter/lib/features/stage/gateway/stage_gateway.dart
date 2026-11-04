import 'package:undian_core/undian_core.dart';

/// Data awal panggung: peserta, hadiah, dan pemenang yang sudah ada.
class StageData {
  const StageData({
    required this.participants,
    required this.prizes,
    required this.winners,
    this.allowMultipleWins = false,
  });

  final List<Participant> participants;
  final List<Prize> prizes;
  final List<Winner> winners;
  final bool allowMultipleWins;
}

/// Hasil satu putaran undian.
class DrawOutcome {
  const DrawOutcome({required this.winners, required this.records, required this.pool});

  /// Pemenang berurutan, sudah ditentukan sebelum animasi dimulai.
  final List<Participant> winners;

  /// Catatan pemenang baru (status sah) untuk ditambahkan ke daftar pemenang.
  final List<Winner> records;

  /// Peserta berhak saat undian; dipakai untuk nama-nama yang berputar di animasi.
  final List<Participant> pool;
}

/// Sumber data panggung. Panggung tidak tahu apakah undian dicatat di server atau di laptop
/// (mode offline).
abstract interface class StageGateway {
  Future<StageData> load();

  /// Mengundi [count] pemenang untuk [prize]. [current] adalah keadaan panggung saat ini.
  Future<DrawOutcome> draw({required Prize prize, required int count, required StageData current});

  /// Membatalkan [winner] dengan [status] hangus atau diskualifikasi; unit hadiahnya kembali ke
  /// stok.
  Future<void> cancelWinner(Winner winner, WinnerStatus status, String reason);
}
