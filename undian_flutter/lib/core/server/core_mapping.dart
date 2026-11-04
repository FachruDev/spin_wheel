import 'package:undian_client/undian_client.dart' as api;
import 'package:undian_core/undian_core.dart';

// Konversi model server (undian_client) ke model logika undian (undian_core).

Participant toCoreParticipant(api.EventParticipant p) => Participant(
  id: p.id!,
  nik: p.nik,
  name: p.name,
  area: p.area,
  department: p.department,
  employmentStatus: p.employmentStatus,
  groups: p.groups.toSet(),
  points: p.points,
);

Prize toCorePrize(api.EventPrize p) => Prize(
  id: p.id!,
  name: p.name,
  kind: PrizeKind.values.byName(p.kind.name),
  quantity: p.quantity,
  eligibleGroups: p.eligibleGroups.toSet(),
  openToAll: p.openToAll,
);

Winner toCoreWinner(api.PrizeWinner w) =>
    Winner(participantId: w.participantId, prizeId: w.prizeId, status: w.status.toCore);

/// Aturan status pemenang dari `undian_core`, untuk model server.
extension WinnerStatusRules on api.WinnerStatus {
  WinnerStatus get toCore => WinnerStatus.values.byName(name);

  /// Kemenangan sah yang memakai satu unit hadiah (bukan hangus atau diskualifikasi).
  bool get usesStock => toCore.usesStock;

  /// Hangus atau diskualifikasi: final, unit hadiahnya sudah kembali ke stok.
  bool get isFinal => toCore.isFinal;
}
