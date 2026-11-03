import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';
import 'package:undian_core/undian_core.dart' as core;

import '../../core/server/core_mapping.dart';
import '../../core/server/server_providers.dart';
import '../../core/ui/async_view.dart';
import '../../core/ui/dialogs.dart';
import '../events/event_providers.dart';
import '../stage/widgets/common.dart';
import 'prize_form_dialog.dart';

/// Daftar hadiah acara: stok, sisa, dan jumlah peserta berhak per hadiah.
class PrizesTab extends ConsumerWidget {
  const PrizesTab({super.key, required this.event, required this.canManage});

  final DrawEvent event;
  final bool canManage;

  int get _eventId => event.id!;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prizes = ref.watch(prizesProvider(_eventId));
    final participants = ref.watch(participantsProvider(_eventId)).value ?? const [];
    final winners = ref.watch(winnersProvider(_eventId)).value ?? const [];
    final corePeople = [for (final p in participants) toCoreParticipant(p)];
    final coreWinners = [for (final w in winners) toCoreWinner(w)];
    int eligible(EventPrize prize) => core.DrawEngine.eligible(
      participants: corePeople,
      prize: toCorePrize(prize.copyWith(id: prize.id ?? -1)),
      winners: coreWinners,
      allowMultipleWins: event.allowMultipleWins,
    ).length;

    Future<void> edit(EventPrize initial) async {
      final draft = await showPrizeForm(
        context,
        initial: initial,
        groupCounts: groupCounts(participants),
        eligibleCount: eligible,
      );
      if (draft == null || !context.mounted) return;
      try {
        await ref.read(clientProvider).prize.save(draft);
        ref.invalidate(prizesProvider(_eventId));
      } catch (e) {
        if (context.mounted) showErrorSnack(context, e);
      }
    }

    return AsyncView(
      value: prizes,
      onRetry: () => ref.invalidate(prizesProvider(_eventId)),
      data: (list) {
        EventPrize blank() => EventPrize(
          eventId: _eventId,
          name: '',
          kind: PrizeKind.doorprize,
          quantity: 1,
          sortOrder: list.fold(0, (m, p) => p.sortOrder > m ? p.sortOrder : m) + 1,
          eligibleGroups: const [],
          openToAll: false,
        );
        final addButton = FilledButton.icon(
          onPressed: () => edit(blank()),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tambah hadiah'),
        );
        if (list.isEmpty) {
          return EmptyView(
            icon: Icons.card_giftcard_rounded,
            title: 'Belum ada hadiah',
            message: canManage
                ? 'Tambahkan doorprize dan grand prize beserta jumlah unit dan grup peserta yang berhak.'
                : 'Admin belum menambahkan hadiah.',
            action: canManage ? addButton : null,
          );
        }
        final totalUnits = list.fold(0, (sum, p) => sum + p.quantity);
        final totalLeft = list.fold(0, (sum, p) => sum + remainingUnits(p, winners));
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(child: Text('${list.length} hadiah · $totalLeft dari $totalUnits unit belum terundi')),
                if (canManage) addButton,
              ],
            ),
            const SizedBox(height: 12),
            for (final prize in list)
              _PrizeCard(
                prize: prize,
                remaining: remainingUnits(prize, winners),
                eligible: eligible(prize),
                onEdit: canManage ? () => edit(prize) : null,
                onDelete: canManage ? () => _delete(context, ref, prize) : null,
              ),
          ],
        );
      },
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, EventPrize prize) async {
    final ok = await confirm(
      context,
      title: 'Hapus "${prize.name}"?',
      message: 'Hadiah yang sudah pernah diundi tidak bisa dihapus.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(clientProvider).prize.delete(prize.id!);
      ref.invalidate(prizesProvider(_eventId));
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }
}

class _PrizeCard extends StatelessWidget {
  const _PrizeCard({
    required this.prize,
    required this.remaining,
    required this.eligible,
    required this.onEdit,
    required this.onDelete,
  });

  final EventPrize prize;
  final int remaining;
  final int eligible;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grand = prize.kind == PrizeKind.grandprize;
    final who = prize.openToAll ? 'Semua peserta' : prize.eligibleGroups.join(', ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: grand ? theme.colorScheme.tertiaryContainer : theme.colorScheme.secondaryContainer,
          child: Icon(prizeIcon(toCorePrizeForIcon(prize))),
        ),
        title: Text(prize.name),
        subtitle: Text(
          '${grand ? 'Grand prize' : 'Doorprize'} · sisa $remaining dari ${prize.quantity} unit\n'
          'Berhak: $who ($eligible peserta)',
        ),
        isThreeLine: true,
        trailing: onEdit == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(tooltip: 'Ubah', onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
                  IconButton(tooltip: 'Hapus', onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded)),
                ],
              ),
      ),
    );
  }
}

/// prizeIcon memakai model undian_core; hadiah yang belum tersimpan belum punya id.
core.Prize toCorePrizeForIcon(EventPrize prize) => toCorePrize(prize.copyWith(id: prize.id ?? -1));
