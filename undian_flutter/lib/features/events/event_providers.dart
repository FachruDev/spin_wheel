import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:undian_client/undian_client.dart';

import '../../core/data/repository_providers.dart';
import '../../core/server/core_mapping.dart';

/// Penanda satu acara di dalam satu organisasi (dipakai sebagai argumen family).
typedef EventRef = ({int organizationId, int eventId});

final eventsProvider = FutureProvider.autoDispose.family<List<DrawEvent>, int>(
  (ref, organizationId) => ref.watch(repositoryProvider).events(organizationId),
);

final eventProvider = FutureProvider.autoDispose.family<DrawEvent, EventRef>((ref, key) async {
  final events = await ref.watch(eventsProvider(key.organizationId).future);
  return events.firstWhere(
    (e) => e.id == key.eventId,
    orElse: () => throw UndianException(message: 'Acara tidak ditemukan atau Anda tidak punya akses.'),
  );
});

final participantsProvider = FutureProvider.autoDispose.family<List<EventParticipant>, int>(
  (ref, eventId) => ref.watch(repositoryProvider).participants(eventId),
);

final prizesProvider = FutureProvider.autoDispose.family<List<EventPrize>, int>(
  (ref, eventId) => ref.watch(repositoryProvider).prizes(eventId),
);

final winnersProvider = FutureProvider.autoDispose.family<List<PrizeWinner>, int>(
  (ref, eventId) => ref.watch(repositoryProvider).winners(eventId),
);

/// Semua grup yang dipakai peserta beserta jumlah anggotanya, urut abjad.
Map<String, int> groupCounts(Iterable<EventParticipant> participants) {
  final counts = <String, int>{};
  for (final p in participants) {
    for (final g in p.groups) {
      counts[g] = (counts[g] ?? 0) + 1;
    }
  }
  return Map.fromEntries(counts.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
}

/// Sisa unit hadiah: jumlah unit dikurangi pemenang sah (bukan hangus atau diskualifikasi).
int remainingUnits(EventPrize prize, Iterable<PrizeWinner> winners) {
  final used = winners.where((w) => w.prizeId == prize.id && w.status.usesStock).length;
  return prize.quantity - used;
}
