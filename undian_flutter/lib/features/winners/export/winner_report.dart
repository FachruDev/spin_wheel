import 'dart:typed_data';

import 'package:undian_client/undian_client.dart';

import '../../../core/server/core_mapping.dart';
import '../../../core/ui/format.dart';

String winnerStatusLabel(WinnerStatus status) => switch (status) {
  WinnerStatus.sah => 'Belum diserahkan',
  WinnerStatus.diserahkan => 'Diserahkan',
  WinnerStatus.ditransfer => 'Ditransfer',
  WinnerStatus.hangus => 'Hangus',
  WinnerStatus.diskualifikasi => 'Didiskualifikasi',
};

String prizeKindLabel(PrizeKind kind) => switch (kind) {
  PrizeKind.doorprize => 'Doorprize',
  PrizeKind.grandprize => 'Grand prize',
};

/// Satu pemenang lengkap dengan data peserta dan hadiahnya.
class WinnerReportRow {
  const WinnerReportRow({required this.winner, required this.participant, required this.prize});

  final PrizeWinner winner;
  final EventParticipant participant;
  final EventPrize prize;

  /// Pemenang sah (bukan hangus atau didiskualifikasi).
  bool get isValid => winner.status.usesStock;
}

/// Rekap satu hadiah: unit, pemenang sah, hangus, didiskualifikasi, dan sisa.
class PrizeSummary {
  const PrizeSummary({required this.prize, required this.valid, required this.forfeited, this.disqualified = 0});

  final EventPrize prize;
  final int valid;
  final int forfeited;
  final int disqualified;

  int get remaining => prize.quantity - valid;
}

/// Semua data untuk laporan pemenang satu acara (Excel dan PDF).
class WinnerReport {
  WinnerReport({
    required this.organizationName,
    required this.event,
    required List<EventPrize> prizes,
    required List<EventParticipant> participants,
    required List<PrizeWinner> winners,
    this.logo,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now(),
       participantCount = participants.length,
       prizes = [...prizes]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)) {
    final personById = {for (final p in participants) p.id: p};
    final prizeById = {for (final p in prizes) p.id: p};
    final order = {for (var i = 0; i < this.prizes.length; i++) this.prizes[i].id: i};
    rows =
        [
          for (final w in winners)
            if ((personById[w.participantId], prizeById[w.prizeId]) case (final person?, final prize?))
              WinnerReportRow(winner: w, participant: person, prize: prize),
        ]..sort(
          (a, b) => [
            order[a.prize.id]!.compareTo(order[b.prize.id]!),
            a.winner.roundNo.compareTo(b.winner.roundNo),
            (a.winner.id ?? 0).compareTo(b.winner.id ?? 0),
          ].firstWhere((c) => c != 0, orElse: () => 0),
        );
  }

  final String organizationName;
  final DrawEvent event;
  final Uint8List? logo;
  final DateTime generatedAt;
  final int participantCount;

  /// Hadiah urut sesuai rundown.
  final List<EventPrize> prizes;

  /// Semua pemenang (termasuk hangus dan didiskualifikasi), urut per hadiah lalu putaran.
  late final List<WinnerReportRow> rows;

  List<WinnerReportRow> get validRows => [
    for (final r in rows)
      if (r.isValid) r,
  ];

  List<PrizeSummary> get summaries => [
    for (final prize in prizes)
      PrizeSummary(
        prize: prize,
        valid: rows.where((r) => r.prize.id == prize.id && r.isValid).length,
        forfeited: _count(prize, WinnerStatus.hangus),
        disqualified: _count(prize, WinnerStatus.diskualifikasi),
      ),
  ];

  int _count(EventPrize prize, WinnerStatus status) =>
      rows.where((r) => r.prize.id == prize.id && r.winner.status == status).length;

  /// Pemenang sah dikelompokkan per area peserta (untuk bukti tanda terima), urut nama area.
  Map<String, List<WinnerReportRow>> get validRowsByArea {
    final groups = <String, List<WinnerReportRow>>{};
    for (final row in validRows) {
      final area = row.participant.area.trim().isEmpty ? 'Tanpa area' : row.participant.area.trim();
      groups.putIfAbsent(area, () => []).add(row);
    }
    return Map.fromEntries(groups.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  /// Dasar nama file, mis. "pemenang_hut_2026".
  String fileName(String prefix, String extension) => '${prefix}_${fileSlug(event.name)}.$extension';
}
