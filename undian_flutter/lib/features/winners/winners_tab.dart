import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/server/server_providers.dart';
import '../../core/ui/async_view.dart';
import '../../core/ui/dialogs.dart';
import '../../core/ui/format.dart';
import '../events/event_providers.dart';

/// Daftar pemenang per putaran, dengan aksi ubah status (diserahkan, ditransfer, hangus).
class WinnersTab extends ConsumerWidget {
  const WinnersTab({super.key, required this.eventId, required this.canDraw});

  final int eventId;
  final bool canDraw;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winners = ref.watch(winnersProvider(eventId));
    final participants = ref.watch(participantsProvider(eventId)).value ?? const [];
    final prizes = ref.watch(prizesProvider(eventId)).value ?? const [];
    final personById = {for (final p in participants) p.id: p};
    final prizeById = {for (final p in prizes) p.id: p};
    return AsyncView(
      value: winners,
      onRetry: () => ref.invalidate(winnersProvider(eventId)),
      data: (list) {
        if (list.isEmpty) {
          return const EmptyView(
            icon: Icons.emoji_events_outlined,
            title: 'Belum ada pemenang',
            message: 'Buka panggung untuk mulai mengundi. Pemenang tersimpan otomatis di server.',
          );
        }
        final ordered = list.reversed.toList();
        final valid = list.where((w) => w.status != WinnerStatus.hangus).length;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('$valid pemenang sah · ${list.length - valid} hangus'),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  for (final w in ordered)
                    _WinnerRow(
                      winner: w,
                      person: personById[w.participantId],
                      prize: prizeById[w.prizeId],
                      onStatus: canDraw && w.status != WinnerStatus.hangus
                          ? (status) => _changeStatus(context, ref, w, status, personById[w.participantId]?.name)
                          : null,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    PrizeWinner winner,
    WinnerStatus status,
    String? name,
  ) async {
    String? note;
    if (status == WinnerStatus.hangus) {
      note = await askForfeitReason(context, name ?? 'pemenang ini');
      if (note == null) return;
    }
    try {
      await ref.read(clientProvider).draw.setStatus(winner.id!, status, note);
      ref.invalidate(winnersProvider(eventId));
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }
}

String winnerStatusLabel(WinnerStatus status) => switch (status) {
  WinnerStatus.sah => 'Belum diserahkan',
  WinnerStatus.diserahkan => 'Diserahkan',
  WinnerStatus.ditransfer => 'Ditransfer',
  WinnerStatus.hangus => 'Hangus',
};

class _WinnerRow extends StatelessWidget {
  const _WinnerRow({required this.winner, required this.person, required this.prize, required this.onStatus});

  final PrizeWinner winner;
  final EventParticipant? person;
  final EventPrize? prize;
  final ValueChanged<WinnerStatus>? onStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final forfeited = winner.status == WinnerStatus.hangus;
    final details = [
      prize?.name ?? 'Hadiah #${winner.prizeId}',
      if (person != null) '${person!.nik} · ${person!.area}',
      'putaran ${winner.roundNo} · ${formatDateTime(winner.drawnAt.toLocal())}',
      if (winner.note case final note? when note.isNotEmpty) 'catatan: $note',
    ];
    return ListTile(
      leading: CircleAvatar(child: Text('${winner.roundNo}')),
      title: Text(
        person?.name ?? 'Peserta #${winner.participantId}',
        style: TextStyle(decoration: forfeited ? TextDecoration.lineThrough : null),
      ),
      subtitle: Text(details.join('\n')),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(winnerStatusLabel(winner.status)),
            backgroundColor: forfeited ? theme.colorScheme.errorContainer : null,
          ),
          if (onStatus != null)
            PopupMenuButton<WinnerStatus>(
              tooltip: 'Ubah status',
              onSelected: onStatus,
              itemBuilder: (_) => [
                for (final s in WinnerStatus.values)
                  if (s != winner.status) PopupMenuItem(value: s, child: Text(winnerStatusLabel(s))),
              ],
            ),
        ],
      ),
    );
  }
}
