import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_core/undian_core.dart';

import '../branding/branding.dart';
import '../branding/branding_dialog.dart';
import 'stage_controller.dart';
import 'widgets/common.dart';

/// Panel kendali operator di samping layar panggung (prototipe).
/// Di versi penuh panel ini bisa dibuka di perangkat lain, terhubung lewat server.
class OperatorPanel extends ConsumerWidget {
  const OperatorPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stageControllerProvider);
    final accent = ref.watch(brandingProvider.select((b) => b.accent));
    final controller = ref.read(stageControllerProvider.notifier);
    final theme = Theme.of(context);
    final phase = state.phase;
    final hiddenRun = phase is StageShow && !phase.revealed ? phase : null;
    final shownWinners = [
      for (final w in state.winners.reversed)
        if (hiddenRun == null ||
            w.prizeId != hiddenRun.prize.id ||
            !hiddenRun.winners.any((p) => p.id == w.participantId))
          w,
    ];

    return Material(
      color: const Color(0xFF0D0F1C),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 8, 10),
            child: Row(
              children: [
                Icon(Icons.tune_rounded, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Panel Operator',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(onPressed: onClose, tooltip: 'Sembunyikan (H)', icon: const Icon(Icons.close_rounded)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SectionLabel('Hadiah'),
                for (final prize in state.prizes)
                  _PrizeTile(
                    prize: prize,
                    accent: accent,
                    selected: prize.id == state.selectedPrizeId,
                    remaining: state.remaining(prize),
                    eligible: state.eligibleFor(prize),
                    onTap: () => controller.selectPrize(prize.id),
                  ),
                const SizedBox(height: 16),
                const _SectionLabel('Animasi'),
                SegmentedButton<RevealMode>(
                  segments: [for (final m in RevealMode.values) ButtonSegment(value: m, label: Text(m.label))],
                  selected: {state.mode},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => controller.setMode(s.first),
                ),
                const SizedBox(height: 8),
                Text(state.mode.hint, style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60)),
                if (!state.mode.single) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Expanded(child: Text('Pemenang per putaran')),
                      IconButton.filledTonal(
                        onPressed: state.perRound > 1 ? () => controller.changePerRound(-1) : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${state.perRound}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: state.perRound < state.maxPerRound ? () => controller.changePerRound(1) : null,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                _SectionLabel('Pemenang (${state.winners.where((w) => w.status.usesStock).length})'),
                if (hiddenRun != null)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    title: Text('${hiddenRun.winners.length} pemenang sedang ditampilkan di panggung…'),
                  ),
                if (shownWinners.isEmpty && hiddenRun == null)
                  Text('Belum ada pemenang.', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54)),
                for (final winner in shownWinners.take(50))
                  _WinnerTile(
                    winner: winner,
                    person: state.participantById[winner.participantId]!,
                    prize: state.prizeById(winner.prizeId),
                    onForfeit: state.isAnimating ? null : () => controller.forfeit(winner),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.message case final message?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(message, style: const TextStyle(color: Color(0xFFFFC857))),
                  ),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: state.isAnimating ? null : controller.primaryAction,
                    icon: Icon(phase is StageIdle ? Icons.casino_rounded : Icons.skip_next_rounded),
                    label: Text(switch (phase) {
                      StageIdle() => 'UNDI  (Spasi)',
                      StageShow(revealed: false) => 'Sedang mengundi…',
                      StageShow(revealed: true) => 'LANJUT  (Spasi)',
                    }),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => showBrandingDialog(context),
                        icon: const Icon(Icons.palette_outlined),
                        label: const Text('Tampilan'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: state.isAnimating ? null : controller.reset,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reset demo'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5, color: Colors.white54),
    ),
  );
}

class _PrizeTile extends StatelessWidget {
  const _PrizeTile({
    required this.prize,
    required this.accent,
    required this.selected,
    required this.remaining,
    required this.eligible,
    required this.onTap,
  });

  final Prize prize;
  final Color accent;
  final bool selected;
  final int remaining;
  final List<Participant> eligible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: selected ? accent : Colors.white12, width: selected ? 1.5 : 1),
    );
    final kind = prize.kind == PrizeKind.grandprize ? 'Grand prize' : 'Doorprize';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(prizeIcon(prize), color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prize.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text('$kind · sisa $remaining/${prize.quantity}', style: theme.textTheme.bodySmall),
                      Text(
                        '${eligible.length} berhak · ${DrawEngine.totalPoints(eligible)} poin',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                if (remaining == 0) const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WinnerTile extends StatelessWidget {
  const _WinnerTile({required this.winner, required this.person, required this.prize, required this.onForfeit});

  final Winner winner;
  final Participant person;
  final Prize prize;
  final VoidCallback? onForfeit;

  @override
  Widget build(BuildContext context) {
    final forfeited = winner.status == WinnerStatus.hangus;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        person.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: forfeited ? TextDecoration.lineThrough : null,
          color: forfeited ? Colors.white38 : null,
        ),
      ),
      subtitle: Text('${prize.name} · ${person.area}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: forfeited
          ? const Text(
              'HANGUS',
              style: TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w700),
            )
          : IconButton(
              tooltip: 'Tidak hadir: tandai hangus & kembalikan stok',
              onPressed: onForfeit,
              icon: const Icon(Icons.person_off_outlined),
            ),
    );
  }
}
