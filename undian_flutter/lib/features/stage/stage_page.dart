import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../branding/brand_widgets.dart';
import '../branding/branding.dart';
import 'operator_panel.dart';
import 'stage_controller.dart';
import 'widgets/card_shuffle_view.dart';
import 'widgets/common.dart';
import 'widgets/grand_reel_view.dart';
import 'widgets/idle_view.dart';
import 'widgets/nik_reveal_view.dart';
import 'widgets/stage_background.dart';

/// Layar panggung + panel operator.
/// Spasi/Enter = undi/lanjut, H = tampil/sembunyikan panel, Esc = keluar panggung.
///
/// Harus berada di bawah ProviderScope yang meng-override [stageGatewayProvider] dan
/// [stageBrandingProvider] (lihat stage_routes.dart).
class StagePage extends ConsumerStatefulWidget {
  const StagePage({super.key});

  /// Kembali ke halaman sebelumnya, atau ke beranda bila panggung dibuka langsung.
  static void exit(BuildContext context) {
    final router = GoRouter.of(context);
    router.canPop() ? router.pop() : router.go('/');
  }

  @override
  ConsumerState<StagePage> createState() => _StagePageState();
}

class _StagePageState extends ConsumerState<StagePage> {
  var _panelOpen = true;
  ModalRoute<Object?>? _route;

  @override
  void initState() {
    super.initState();
    // Ditangkap global, bukan lewat fokus: klik di panel tidak boleh membuat Spasi mati.
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !mounted) return false;
    // Abaikan saat dialog terbuka atau operator sedang mengetik.
    if (_route?.isCurrent == false) return false;
    final focused = FocusManager.instance.primaryFocus?.context;
    if (focused?.findAncestorWidgetOfExactType<EditableText>() != null) return false;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space || key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      ref.read(stageControllerProvider.notifier).primaryAction();
      return true;
    }
    if (key == LogicalKeyboardKey.keyH) {
      setState(() => _panelOpen = !_panelOpen);
      return true;
    }
    if (key == LogicalKeyboardKey.escape && !ref.read(stageControllerProvider).isAnimating) {
      StagePage.exit(context);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _route = ModalRoute.of(context);
    final state = ref.watch(stageControllerProvider);
    final branding = ref.watch(stageBrandingProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      // Tombol di halaman ini tidak mengambil fokus, supaya Spasi tidak ikut menekan tombol.
      body: ExcludeFocus(
        child: Row(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  StageBackground(
                    primary: branding.primary,
                    accent: branding.accent,
                    energy: state.isAnimating ? 1 : 0,
                  ),
                  StageCanvas(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(child: _content(state, branding)),
                        Positioned(left: 80, top: 56, child: StageHeader(branding: branding)),
                      ],
                    ),
                  ),
                  if (!_panelOpen)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton.filledTonal(
                        tooltip: 'Panel operator (H)',
                        onPressed: () => setState(() => _panelOpen = true),
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ),
                ],
              ),
            ),
            if (_panelOpen)
              SizedBox(width: 380, child: OperatorPanel(onClose: () => setState(() => _panelOpen = false))),
          ],
        ),
      ),
    );
  }

  Widget _content(StageState state, Branding branding) {
    if (state.loading) {
      return const Center(
        child: Text('Memuat data acara…', style: TextStyle(fontSize: 40, color: Colors.white70)),
      );
    }
    switch (state.phase) {
      case StageIdle():
        final prize = state.selectedPrize;
        return IdleView(
          branding: branding,
          prize: prize,
          remaining: prize == null ? 0 : state.remaining(prize),
          eligibleCount: prize == null ? 0 : state.eligibleFor(prize).length,
        );
      case StageShow show:
        void done() => ref.read(stageControllerProvider.notifier).finishReveal(show.runId);
        return KeyedSubtree(
          key: ValueKey(show.runId),
          child: switch (show.mode) {
            RevealMode.kartu => CardShuffleView(
              prize: show.prize,
              winners: show.winners,
              pool: show.pool,
              primary: branding.primary,
              accent: branding.accent,
              onFinished: done,
            ),
            RevealMode.panggung => GrandReelView(
              prize: show.prize,
              winner: show.winners.first,
              pool: show.pool,
              primary: branding.primary,
              accent: branding.accent,
              onFinished: done,
            ),
            RevealMode.nik => NikRevealView(
              prize: show.prize,
              winner: show.winners.first,
              pool: show.pool,
              primary: branding.primary,
              accent: branding.accent,
              onFinished: done,
            ),
          },
        );
    }
  }
}
