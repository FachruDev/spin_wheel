import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_core/undian_core.dart';

import '../../core/ui/dialogs.dart';
import 'stage_controller.dart';
import 'stage_page.dart';
import 'widgets/common.dart';

/// Panel kendali operator di samping layar panggung.
class OperatorPanel extends ConsumerWidget {
  const OperatorPanel({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stageControllerProvider);
    final accent = ref.watch(stageBrandingProvider).accent;
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
                    onCancel: state.isLocked
                        ? null
                        : (status) async {
                            final name = state.participantById[winner.participantId]!.name;
                            final prizeName = state.prizeById(winner.prizeId).name;
                            final ask = status == WinnerStatus.hangus
                                ? askForfeitReason(context, name)
                                : askDisqualifyReason(context, name, prizeName);
                            final reason = await ask;
                            if (reason != null) await controller.cancelWinner(winner, status, reason);
                          },
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
                    onPressed: state.isLocked ? null : controller.primaryAction,
                    icon: Icon(phase is StageIdle ? Icons.casino_rounded : Icons.skip_next_rounded),
                    label: Text(switch (phase) {
                      _ when state.loading => 'Memuat…',
                      _ when state.busy => 'Menghubungi server…',
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
                        onPressed: state.isLocked ? null : controller.reload,
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Muat ulang'),
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: state.isAnimating ? null : () => StagePage.exit(context),
                        icon: const Icon(Icons.logout_rounded),
                        label: const Text('Keluar'),
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
  const _WinnerTile({required this.winner, required this.person, required this.prize, required this.onCancel});

  final Winner winner;
  final Participant person;
  final Prize prize;

  /// Membatalkan pemenang dengan status hangus atau diskualifikasi.
  final ValueChanged<WinnerStatus>? onCancel;

  @override
  Widget build(BuildContext context) {
    final cancelled = winner.status.isFinal;
    final forfeited = winner.status == WinnerStatus.hangus;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        person.name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          decoration: cancelled ? TextDecoration.lineThrough : null,
          color: cancelled ? Colors.white38 : null,
        ),
      ),
      subtitle: Text('${prize.name} · ${person.area}', maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: cancelled
          ? Text(
              forfeited ? 'HANGUS' : 'DISKUALIFIKASI',
              style: TextStyle(
                color: forfeited ? const Color(0xFFF87171) : const Color(0xFFFBBF24),
                fontWeight: FontWeight.w700,
              ),
            )
          : PopupMenuButton<WinnerStatus>(
              tooltip: 'Batalkan pemenang',
              enabled: onCancel != null,
              onSelected: onCancel,
              icon: const Icon(Icons.person_off_outlined),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: WinnerStatus.hangus,
                  child: ListTile(
                    leading: Icon(Icons.event_busy_rounded),
                    title: Text('Tidak hadir: hangus'),
                    subtitle: Text('Tidak ikut undian apa pun lagi'),
                  ),
                ),
                PopupMenuItem(
                  value: WinnerStatus.diskualifikasi,
                  child: ListTile(
                    leading: Icon(Icons.gpp_bad_outlined),
                    title: Text('Tidak memenuhi syarat: diskualifikasi'),
                    subtitle: Text('Tetap ikut undian hadiah lain'),
                  ),
                ),
              ],
            ),
    );
  }
}
