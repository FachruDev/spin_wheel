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

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'winner_status.dart' as _i2;

/// Hasil undian: satu peserta memenangkan satu unit hadiah.
abstract class PrizeWinner implements _i1.SerializableModel {
  PrizeWinner._({
    this.id,
    required this.eventId,
    required this.prizeId,
    required this.participantId,
    required this.roundNo,
    required this.status,
    required this.drawnAt,
    required this.drawnBy,
    this.note,
  });

  factory PrizeWinner({
    int? id,
    required int eventId,
    required int prizeId,
    required int participantId,
    required int roundNo,
    required _i2.WinnerStatus status,
    required DateTime drawnAt,
    required _i1.UuidValue drawnBy,
    String? note,
  }) = _PrizeWinnerImpl;

  factory PrizeWinner.fromJson(Map<String, dynamic> jsonSerialization) {
    return PrizeWinner(
      id: jsonSerialization['id'] as int?,
      eventId: jsonSerialization['eventId'] as int,
      prizeId: jsonSerialization['prizeId'] as int,
      participantId: jsonSerialization['participantId'] as int,
      roundNo: jsonSerialization['roundNo'] as int,
      status: _i2.WinnerStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      drawnAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['drawnAt']),
      drawnBy: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['drawnBy'],
      ),
      note: jsonSerialization['note'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int eventId;

  int prizeId;

  int participantId;

  /// Nomor putaran undian dalam acara (1, 2, 3, ...).
  int roundNo;

  _i2.WinnerStatus status;

  DateTime drawnAt;

  /// Operator yang menjalankan undian.
  _i1.UuidValue drawnBy;

  /// Alasan perubahan status, mis. "Tidak hadir saat dipanggil".
  String? note;

  /// Returns a shallow copy of this [PrizeWinner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PrizeWinner copyWith({
    int? id,
    int? eventId,
    int? prizeId,
    int? participantId,
    int? roundNo,
    _i2.WinnerStatus? status,
    DateTime? drawnAt,
    _i1.UuidValue? drawnBy,
    String? note,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PrizeWinner',
      if (id != null) 'id': id,
      'eventId': eventId,
      'prizeId': prizeId,
      'participantId': participantId,
      'roundNo': roundNo,
      'status': status.toJson(),
      'drawnAt': drawnAt.toJson(),
      'drawnBy': drawnBy.toJson(),
      if (note != null) 'note': note,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PrizeWinnerImpl extends PrizeWinner {
  _PrizeWinnerImpl({
    int? id,
    required int eventId,
    required int prizeId,
    required int participantId,
    required int roundNo,
    required _i2.WinnerStatus status,
    required DateTime drawnAt,
    required _i1.UuidValue drawnBy,
    String? note,
  }) : super._(
         id: id,
         eventId: eventId,
         prizeId: prizeId,
         participantId: participantId,
         roundNo: roundNo,
         status: status,
         drawnAt: drawnAt,
         drawnBy: drawnBy,
         note: note,
       );

  /// Returns a shallow copy of this [PrizeWinner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PrizeWinner copyWith({
    Object? id = _Undefined,
    int? eventId,
    int? prizeId,
    int? participantId,
    int? roundNo,
    _i2.WinnerStatus? status,
    DateTime? drawnAt,
    _i1.UuidValue? drawnBy,
    Object? note = _Undefined,
  }) {
    return PrizeWinner(
      id: id is int? ? id : this.id,
      eventId: eventId ?? this.eventId,
      prizeId: prizeId ?? this.prizeId,
      participantId: participantId ?? this.participantId,
      roundNo: roundNo ?? this.roundNo,
      status: status ?? this.status,
      drawnAt: drawnAt ?? this.drawnAt,
      drawnBy: drawnBy ?? this.drawnBy,
      note: note is String? ? note : this.note,
    );
  }
}
