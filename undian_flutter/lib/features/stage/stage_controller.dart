import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_core/undian_core.dart';

import '../../core/ui/async_view.dart';
import '../branding/branding.dart';
import 'gateway/stage_gateway.dart';
import 'stage_state.dart';

export 'stage_state.dart';

/// Sumber data panggung. Selalu di-override per halaman acara (server atau mode offline).
final stageGatewayProvider = Provider<StageGateway>(
  (ref) => throw UnimplementedError('stageGatewayProvider harus di-override'),
  dependencies: const [],
);

/// Identitas yang tampil di panggung. Selalu di-override per halaman.
final stageBrandingProvider = Provider<Branding>(
  (ref) => throw UnimplementedError('stageBrandingProvider harus di-override'),
  dependencies: const [],
);

final stageControllerProvider = NotifierProvider<StageController, StageState>(
  StageController.new,
  dependencies: [stageGatewayProvider],
);

/// Alur layar panggung: muat data → pilih hadiah → undi → animasi → lanjut.
class StageController extends Notifier<StageState> {
  var _runCounter = 0;
  late StageGateway _gateway;

  /// Selesai saat data awal sudah dimuat (dipakai tes).
  late Future<void> loaded;

  @override
  StageState build() {
    _gateway = ref.watch(stageGatewayProvider);
    loaded = _load();
    return StageState(loading: true);
  }

  Future<void> _load() async {
    try {
      final data = await _gateway.load();
      if (!ref.mounted) return;
      final loadedState = StageState(
        participants: data.participants,
        prizes: data.prizes,
        winners: data.winners,
        allowMultipleWins: data.allowMultipleWins,
      );
      final first = data.prizes.where((p) => loadedState.remaining(p) > 0).firstOrNull ?? data.prizes.firstOrNull;
      state = first == null
          ? loadedState.copyWith(message: 'Belum ada hadiah. Tambahkan hadiah di halaman acara.')
          : _withPrize(loadedState, first);
    } catch (e) {
      if (ref.mounted) state = state.copyWith(loading: false, message: describeError(e));
    }
  }

  StageState _withPrize(StageState s, Prize prize) {
    final mode = prize.kind == PrizeKind.grandprize ? RevealMode.panggung : RevealMode.kartu;
    final next = s.copyWith(selectedPrizeId: prize.id, mode: mode, phase: const StageIdle(), message: null);
    return next.copyWith(perRound: _defaultPerRound(next));
  }

  int _defaultPerRound(StageState s) => min(10, s.maxPerRound);

  void selectPrize(int prizeId) {
    if (state.isLocked) return;
    state = _withPrize(state, state.prizeById(prizeId));
  }

  void setMode(RevealMode mode) {
    if (state.isLocked) return;
    final next = state.copyWith(mode: mode, phase: const StageIdle(), message: null);
    state = next.copyWith(perRound: _defaultPerRound(next));
  }

  void changePerRound(int delta) {
    if (state.isLocked) return;
    state = state.copyWith(perRound: (state.perRound + delta).clamp(1, state.maxPerRound));
  }

  /// Tombol utama (Spasi): undi saat siap, lanjut setelah pemenang tampil.
  Future<void> primaryAction() async {
    if (state.loading || state.busy) return;
    switch (state.phase) {
      case StageIdle():
        await _draw();
      case StageShow(revealed: false):
        break;
      case StageShow(revealed: true):
        final next = state.copyWith(phase: const StageIdle(), message: null);
        state = next.copyWith(perRound: min(next.perRound, next.maxPerRound));
    }
  }

  Future<void> _draw() async {
    final prize = state.selectedPrize;
    if (prize == null) {
      state = state.copyWith(message: 'Pilih hadiah dulu di panel operator.');
      return;
    }
    state = state.copyWith(busy: true, message: null);
    try {
      final current = StageData(
        participants: state.participants,
        prizes: state.prizes,
        winners: state.winners,
        allowMultipleWins: state.allowMultipleWins,
      );
      final outcome = await _gateway.draw(prize: prize, count: state.perRound, current: current);
      if (!ref.mounted) return;
      state = state.copyWith(
        busy: false,
        winners: [...state.winners, ...outcome.records],
        phase: StageShow(
          runId: ++_runCounter,
          prize: prize,
          mode: state.mode,
          winners: outcome.winners,
          pool: outcome.pool.isEmpty ? outcome.winners : outcome.pool,
        ),
      );
    } on DrawException catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, message: e.message);
    } catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, message: describeError(e));
    }
  }

  void finishReveal(int runId) {
    final phase = state.phase;
    if (phase is StageShow && phase.runId == runId && !phase.revealed) {
      state = state.copyWith(phase: phase.reveal());
    }
  }

  /// Membatalkan pemenang: hangus (tidak hadir) atau diskualifikasi (tidak memenuhi syarat
  /// hadiah ini). Unitnya kembali ke stok untuk diundi ulang.
  Future<void> cancelWinner(Winner winner, WinnerStatus status, String reason) async {
    if (state.isLocked || !status.isFinal) return;
    state = state.copyWith(busy: true, message: null);
    try {
      await _gateway.cancelWinner(winner, status, reason);
      if (!ref.mounted) return;
      final name = state.participantById[winner.participantId]?.name ?? 'Pemenang';
      final prize = state.prizeById(winner.prizeId).name;
      state = state.copyWith(
        busy: false,
        winners: [
          for (final w in state.winners)
            w.participantId == winner.participantId && w.prizeId == winner.prizeId ? w.copyWith(status: status) : w,
        ],
        message: status == WinnerStatus.hangus
            ? '$name hangus. 1 unit kembali ke stok untuk diundi ulang.'
            : '$name didiskualifikasi dari $prize. 1 unit kembali ke stok; $name tetap ikut undian hadiah lain.',
      );
    } catch (e) {
      if (ref.mounted) state = state.copyWith(busy: false, message: describeError(e));
    }
  }

  /// Memuat ulang data dari sumbernya.
  void reload() => ref.invalidateSelf();
}
