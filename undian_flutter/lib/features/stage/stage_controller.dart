import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_core/undian_core.dart';

import 'demo_data.dart';

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
    required this.participants,
    required this.prizes,
    this.winners = const [],
    this.selectedPrizeId,
    this.mode = RevealMode.kartu,
    this.perRound = 1,
    this.phase = const StageIdle(),
    this.message,
  }) : participantById = {for (final p in participants) p.id: p};

  final List<Participant> participants;
  final Map<int, Participant> participantById;
  final List<Prize> prizes;
  final List<Winner> winners;
  final int? selectedPrizeId;
  final RevealMode mode;
  final int perRound;
  final StagePhase phase;

  /// Pesan untuk operator (mis. stok habis).
  final String? message;

  Prize? get selectedPrize => prizes.where((p) => p.id == selectedPrizeId).firstOrNull;

  Prize prizeById(int id) => prizes.firstWhere((p) => p.id == id);

  bool get isAnimating => switch (phase) {
    StageShow(revealed: false) => true,
    _ => false,
  };

  int remaining(Prize prize) => DrawEngine.remainingStock(prize, winners);

  List<Participant> eligibleFor(Prize prize) =>
      DrawEngine.eligible(participants: participants, prize: prize, winners: winners);

  /// Batas pemenang per putaran: 1 untuk mode tunggal, selain itu sisa stok (maks. 20 kartu).
  int get maxPerRound {
    final prize = selectedPrize;
    if (prize == null || mode.single) return 1;
    return max(1, min(20, remaining(prize)));
  }

  static const _keep = Object();

  StageState copyWith({
    List<Winner>? winners,
    int? selectedPrizeId,
    RevealMode? mode,
    int? perRound,
    StagePhase? phase,
    Object? message = _keep,
  }) => StageState(
    participants: participants,
    prizes: prizes,
    winners: winners ?? this.winners,
    selectedPrizeId: selectedPrizeId ?? this.selectedPrizeId,
    mode: mode ?? this.mode,
    perRound: perRound ?? this.perRound,
    phase: phase ?? this.phase,
    message: identical(message, _keep) ? this.message : message as String?,
  );
}

final drawEngineProvider = Provider<DrawEngine>((ref) => DrawEngine());

final stageControllerProvider = NotifierProvider<StageController, StageState>(StageController.new);

/// Alur layar panggung: pilih hadiah → undi → animasi → lanjut.
///
/// Di prototipe ini undian dijalankan lokal dengan [DrawEngine]; di versi penuh langkah
/// [_draw] memanggil endpoint server, dan hasilnya disiarkan ke layar panggung.
class StageController extends Notifier<StageState> {
  var _runCounter = 0;

  @override
  StageState build() {
    final prizes = DemoData.prizes();
    return _withPrize(StageState(participants: DemoData.participants(), prizes: prizes), prizes.first);
  }

  StageState _withPrize(StageState s, Prize prize) {
    final mode = prize.kind == PrizeKind.grandprize ? RevealMode.panggung : RevealMode.kartu;
    final next = s.copyWith(selectedPrizeId: prize.id, mode: mode, phase: const StageIdle(), message: null);
    return next.copyWith(perRound: _defaultPerRound(next));
  }

  int _defaultPerRound(StageState s) => min(10, s.maxPerRound);

  void selectPrize(int prizeId) {
    if (state.isAnimating) return;
    state = _withPrize(state, state.prizeById(prizeId));
  }

  void setMode(RevealMode mode) {
    if (state.isAnimating) return;
    final next = state.copyWith(mode: mode, phase: const StageIdle(), message: null);
    state = next.copyWith(perRound: _defaultPerRound(next));
  }

  void changePerRound(int delta) {
    if (state.isAnimating) return;
    state = state.copyWith(perRound: (state.perRound + delta).clamp(1, state.maxPerRound));
  }

  /// Tombol utama (Spasi): undi saat siap, lanjut setelah pemenang tampil.
  void primaryAction() {
    switch (state.phase) {
      case StageIdle():
        _draw();
      case StageShow(revealed: false):
        break;
      case StageShow(revealed: true):
        final next = state.copyWith(phase: const StageIdle(), message: null);
        state = next.copyWith(perRound: min(next.perRound, next.maxPerRound));
    }
  }

  void _draw() {
    final prize = state.selectedPrize;
    if (prize == null) {
      state = state.copyWith(message: 'Pilih hadiah dulu di panel operator.');
      return;
    }
    try {
      final pool = state.eligibleFor(prize);
      final drawn = ref
          .read(drawEngineProvider)
          .drawForPrize(participants: state.participants, prize: prize, winners: state.winners, count: state.perRound);
      state = state.copyWith(
        winners: [
          ...state.winners,
          for (final p in drawn) Winner(participantId: p.id, prizeId: prize.id),
        ],
        phase: StageShow(runId: ++_runCounter, prize: prize, mode: state.mode, winners: drawn, pool: pool),
        message: null,
      );
    } on DrawException catch (e) {
      state = state.copyWith(message: e.message);
    }
  }

  void finishReveal(int runId) {
    final phase = state.phase;
    if (phase is StageShow && phase.runId == runId && !phase.revealed) {
      state = state.copyWith(phase: phase.reveal());
    }
  }

  /// Pemenang tidak hadir: tandai hangus, unitnya kembali ke stok untuk diundi ulang.
  void forfeit(Winner winner) {
    if (state.isAnimating) return;
    final name = state.participantById[winner.participantId]?.name ?? 'Pemenang';
    state = state.copyWith(
      winners: [
        for (final w in state.winners)
          w.participantId == winner.participantId && w.prizeId == winner.prizeId
              ? w.copyWith(status: WinnerStatus.hangus)
              : w,
      ],
      message: '$name hangus. 1 unit kembali ke stok untuk diundi ulang.',
    );
  }

  void reset() => ref.invalidateSelf();
}
