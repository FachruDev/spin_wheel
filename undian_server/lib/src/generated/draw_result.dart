/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod/serverpod.dart' as _i1;
import 'event_prize.dart' as _i2;
import 'event_participant.dart' as _i3;
import 'prize_winner.dart' as _i4;
import 'package:undian_server/src/generated/protocol.dart' as _i5;

/// Hasil satu putaran undian, dikirim ke operator dan layar panggung.
abstract class DrawResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DrawResult._({
    required this.roundNo,
    required this.prize,
    required this.winners,
    required this.winnerRecords,
    required this.poolSize,
    required this.poolSample,
  });

  factory DrawResult({
    required int roundNo,
    required _i2.EventPrize prize,
    required List<_i3.EventParticipant> winners,
    required List<_i4.PrizeWinner> winnerRecords,
    required int poolSize,
    required List<_i3.EventParticipant> poolSample,
  }) = _DrawResultImpl;

  factory DrawResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return DrawResult(
      roundNo: jsonSerialization['roundNo'] as int,
      prize: _i5.Protocol().deserialize<_i2.EventPrize>(
        jsonSerialization['prize'],
      ),
      winners: _i5.Protocol().deserialize<List<_i3.EventParticipant>>(
        jsonSerialization['winners'],
      ),
      winnerRecords: _i5.Protocol().deserialize<List<_i4.PrizeWinner>>(
        jsonSerialization['winnerRecords'],
      ),
      poolSize: jsonSerialization['poolSize'] as int,
      poolSample: _i5.Protocol().deserialize<List<_i3.EventParticipant>>(
        jsonSerialization['poolSample'],
      ),
    );
  }

  int roundNo;

  _i2.EventPrize prize;

  /// Pemenang berurutan; indeksnya sama dengan [winnerRecords].
  List<_i3.EventParticipant> winners;

  List<_i4.PrizeWinner> winnerRecords;

  /// Jumlah peserta berhak saat undian.
  int poolSize;

  /// Contoh nama peserta berhak (maks. 200) untuk animasi kocok/drum.
  List<_i3.EventParticipant> poolSample;

  /// Returns a shallow copy of this [DrawResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DrawResult copyWith({
    int? roundNo,
    _i2.EventPrize? prize,
    List<_i3.EventParticipant>? winners,
    List<_i4.PrizeWinner>? winnerRecords,
    int? poolSize,
    List<_i3.EventParticipant>? poolSample,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DrawResult',
      'roundNo': roundNo,
      'prize': prize.toJson(),
      'winners': winners.toJson(valueToJson: (v) => v.toJson()),
      'winnerRecords': winnerRecords.toJson(valueToJson: (v) => v.toJson()),
      'poolSize': poolSize,
      'poolSample': poolSample.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DrawResult',
      'roundNo': roundNo,
      'prize': prize.toJsonForProtocol(),
      'winners': winners.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'winnerRecords': winnerRecords.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'poolSize': poolSize,
      'poolSample': poolSample.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DrawResultImpl extends DrawResult {
  _DrawResultImpl({
    required int roundNo,
    required _i2.EventPrize prize,
    required List<_i3.EventParticipant> winners,
    required List<_i4.PrizeWinner> winnerRecords,
    required int poolSize,
    required List<_i3.EventParticipant> poolSample,
  }) : super._(
         roundNo: roundNo,
         prize: prize,
         winners: winners,
         winnerRecords: winnerRecords,
         poolSize: poolSize,
         poolSample: poolSample,
       );

  /// Returns a shallow copy of this [DrawResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DrawResult copyWith({
    int? roundNo,
    _i2.EventPrize? prize,
    List<_i3.EventParticipant>? winners,
    List<_i4.PrizeWinner>? winnerRecords,
    int? poolSize,
    List<_i3.EventParticipant>? poolSample,
  }) {
    return DrawResult(
      roundNo: roundNo ?? this.roundNo,
      prize: prize ?? this.prize.copyWith(),
      winners: winners ?? this.winners.map((e0) => e0.copyWith()).toList(),
      winnerRecords:
          winnerRecords ??
          this.winnerRecords.map((e0) => e0.copyWith()).toList(),
      poolSize: poolSize ?? this.poolSize,
      poolSample:
          poolSample ?? this.poolSample.map((e0) => e0.copyWith()).toList(),
    );
  }
}
