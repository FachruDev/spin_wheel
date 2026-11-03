import 'dart:math';

import 'models.dart';

class DrawEngine {
  /// [random] bisa diganti saat tes; bawaannya generator acak kriptografis.
  DrawEngine({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// Sisa unit [prize] yang belum terundi. Pemenang hangus mengembalikan unitnya.
  static int remainingStock(Prize prize, Iterable<Winner> winners) {
    final used = winners.where((w) => w.prizeId == prize.id && w.status.usesStock).length;
    return max(0, prize.quantity - used);
  }

  /// Peserta yang berhak ikut undian [prize].
  ///
  /// - Harus anggota salah satu grup hadiah (atau hadiah terbuka untuk semua).
  /// - Peserta yang hangus tidak diikutkan lagi.
  /// - Tanpa [allowMultipleWins], siapa pun yang sudah menang tidak ikut lagi;
  ///   dengan [allowMultipleWins], hanya pemenang hadiah yang sama yang dikeluarkan.
  static List<Participant> eligible({
    required Iterable<Participant> participants,
    required Prize prize,
    Iterable<Winner> winners = const [],
    bool allowMultipleWins = false,
  }) {
    final excluded = <int>{
      for (final w in winners)
        if (w.status == WinnerStatus.hangus || !allowMultipleWins || w.prizeId == prize.id) w.participantId,
    };
    return [
      for (final p in participants)
        if (!excluded.contains(p.id) && (prize.openToAll || p.groups.any(prize.eligibleGroups.contains))) p,
    ];
  }

  static int totalPoints(Iterable<Participant> pool) => pool.fold(0, (sum, p) => sum + p.points);

  /// Mengundi hingga [count] pemenang dari [pool] tanpa pengembalian, dengan peluang
  /// sebanding poin.
  ///
  /// Memakai metode Efraimidis–Spirakis: tiap peserta mendapat kunci ln(u)/poin dan
  /// yang kuncinya terbesar menang. Hasilnya, termasuk urutannya, terdistribusi sama
  /// dengan mengambil satu per satu dari kotak berisi N tiket per peserta lalu
  /// mengeluarkan seluruh tiket pemenang. Itulah perilaku "Generate Poin" aplikasi lama.
  List<Participant> draw(List<Participant> pool, int count) {
    if (count < 0) throw ArgumentError.value(count, 'count', 'tidak boleh negatif');
    for (final p in pool) {
      if (p.points < 1) {
        throw ArgumentError('Poin peserta ${p.nik} harus minimal 1, bukan ${p.points}');
      }
    }
    final keyed = [for (final p in pool) (p, log(_nextOpenUnit()) / p.points)];
    keyed.sort((a, b) => b.$2.compareTo(a.$2));
    return [for (final e in keyed.take(count)) e.$1];
  }

  /// Gabungan cek stok, kelayakan, dan undian untuk satu putaran [prize].
  List<Participant> drawForPrize({
    required Iterable<Participant> participants,
    required Prize prize,
    required Iterable<Winner> winners,
    required int count,
    bool allowMultipleWins = false,
  }) {
    final remaining = remainingStock(prize, winners);
    if (count > remaining) {
      throw DrawException('Stok ${prize.name} tinggal $remaining unit.');
    }
    final pool = eligible(
      participants: participants,
      prize: prize,
      winners: winners,
      allowMultipleWins: allowMultipleWins,
    );
    if (pool.isEmpty) {
      throw DrawException('Tidak ada peserta yang berhak untuk ${prize.name}.');
    }
    if (count > pool.length) {
      throw DrawException(
        'Peserta berhak untuk ${prize.name} hanya ${pool.length} orang, '
        'tidak cukup untuk $count pemenang.',
      );
    }
    return draw(pool, count);
  }

  /// Angka acak di (0, 1) supaya ln(u) selalu terdefinisi.
  double _nextOpenUnit() {
    double u;
    do {
      u = _random.nextDouble();
    } while (u == 0);
    return u;
  }
}

class DrawException implements Exception {
  const DrawException(this.message);

  final String message;

  @override
  String toString() => message;
}
