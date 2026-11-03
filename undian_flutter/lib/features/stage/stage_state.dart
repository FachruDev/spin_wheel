import 'dart:math';

import 'package:undian_core/undian_core.dart';

enum RevealMode {
  kartu('Kartu', 'Kartu Kocok: banyak pemenang sekaligus, kartu berbalik satu per satu.'),
  panggung('Panggung', 'Panggung Utama: drum nama 3D berputar lalu melambat, satu pemenang.'),
  nik('NIK', 'Buka NIK: digit nomor undian terbuka satu per satu, satu pemenang.');

  const RevealMode(this.label, this.hint);

  final String label;
  final String hint;

  /// Mode yang hanya mengundi satu pemenang per putaran.
  bool get single => this != RevealMode.kartu;
}

sealed class StagePhase {
  const StagePhase();
}

final class StageIdle extends StagePhase {
  const StageIdle();
}

final class StageShow extends StagePhase {
  const StageShow({
    required this.runId,
    required this.prize,
    required this.mode,
    required this.winners,
    required this.pool,
    this.revealed = false,
  });

  final int runId;
  final Prize prize;
  final RevealMode mode;

  /// Pemenang putaran ini, sudah ditentukan sebelum animasi dimulai.
  final List<Participant> winners;

  /// Peserta berhak saat undian; dipakai untuk nama-nama yang berputar di animasi.
  final List<Participant> pool;

  /// True setelah animasi selesai menampilkan semua pemenang.
  final bool revealed;

  StageShow reveal() => StageShow(runId: runId, prize: prize, mode: mode, winners: winners, pool: pool, revealed: true);
}

class StageState {
  StageState({
    this.participants = const [],
    this.prizes = const [],
    this.winners = const [],
    this.allowMultipleWins = false,
    this.selectedPrizeId,
    this.mode = RevealMode.kartu,
    this.perRound = 1,
    this.phase = const StageIdle(),
    this.loading = false,
    this.busy = false,
    this.message,
  }) : participantById = {for (final p in participants) p.id: p};

  final List<Participant> participants;
  final Map<int, Participant> participantById;
  final List<Prize> prizes;
  final List<Winner> winners;
  final bool allowMultipleWins;
  final int? selectedPrizeId;
  final RevealMode mode;
  final int perRound;
  final StagePhase phase;

  /// Data awal sedang dimuat.
  final bool loading;

  /// Menunggu jawaban server (undian atau ubah status).
  final bool busy;

  /// Pesan untuk operator (mis. stok habis, gagal terhubung).
  final String? message;

  Prize? get selectedPrize => prizes.where((p) => p.id == selectedPrizeId).firstOrNull;

  Prize prizeById(int id) => prizes.firstWhere((p) => p.id == id);

  bool get isAnimating => switch (phase) {
    StageShow(revealed: false) => true,
    _ => false,
  };

  /// Operator tidak boleh memicu aksi baru selama memuat, menunggu server, atau animasi.
  bool get isLocked => loading || busy || isAnimating;

  int remaining(Prize prize) => DrawEngine.remainingStock(prize, winners);

  List<Participant> eligibleFor(Prize prize) => DrawEngine.eligible(
    participants: participants,
    prize: prize,
    winners: winners,
    allowMultipleWins: allowMultipleWins,
  );

  /// Batas pemenang per putaran: 1 untuk mode tunggal, selain itu sisa stok (maks. 20 kartu).
  int get maxPerRound {
    final prize = selectedPrize;
    if (prize == null || mode.single) return 1;
    return max(1, min(20, remaining(prize)));
  }

  static const _keep = Object();

  StageState copyWith({
    List<Participant>? participants,
    List<Prize>? prizes,
    List<Winner>? winners,
    bool? allowMultipleWins,
    int? selectedPrizeId,
    RevealMode? mode,
    int? perRound,
    StagePhase? phase,
    bool? loading,
    bool? busy,
    Object? message = _keep,
  }) => StageState(
    participants: participants ?? this.participants,
    prizes: prizes ?? this.prizes,
    winners: winners ?? this.winners,
    allowMultipleWins: allowMultipleWins ?? this.allowMultipleWins,
    selectedPrizeId: selectedPrizeId ?? this.selectedPrizeId,
    mode: mode ?? this.mode,
    perRound: perRound ?? this.perRound,
    phase: phase ?? this.phase,
    loading: loading ?? this.loading,
    busy: busy ?? this.busy,
    message: identical(message, _keep) ? this.message : message as String?,
  );
}
