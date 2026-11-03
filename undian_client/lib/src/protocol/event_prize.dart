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
import 'prize_kind.dart' as _i2;
import 'package:undian_client/src/protocol/protocol.dart' as _i3;

/// Hadiah dalam satu acara.
abstract class EventPrize implements _i1.SerializableModel {
  EventPrize._({
    this.id,
    required this.eventId,
    required this.name,
    required this.kind,
    required this.quantity,
    required this.sortOrder,
    required this.eligibleGroups,
    required this.openToAll,
  });

  factory EventPrize({
    int? id,
    required int eventId,
    required String name,
    required _i2.PrizeKind kind,
    required int quantity,
    required int sortOrder,
    required List<String> eligibleGroups,
    required bool openToAll,
  }) = _EventPrizeImpl;

  factory EventPrize.fromJson(Map<String, dynamic> jsonSerialization) {
    return EventPrize(
      id: jsonSerialization['id'] as int?,
      eventId: jsonSerialization['eventId'] as int,
      name: jsonSerialization['name'] as String,
      kind: _i2.PrizeKind.fromJson((jsonSerialization['kind'] as String)),
      quantity: jsonSerialization['quantity'] as int,
      sortOrder: jsonSerialization['sortOrder'] as int,
      eligibleGroups: _i3.Protocol().deserialize<List<String>>(
        jsonSerialization['eligibleGroups'],
      ),
      openToAll: _i1.BoolJsonExtension.fromJson(jsonSerialization['openToAll']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int eventId;

  String name;

  _i2.PrizeKind kind;

  /// Jumlah unit hadiah.
  int quantity;

  /// Urutan tampil di rundown acara.
  int sortOrder;

  /// Peserta berhak jika menjadi anggota salah satu grup ini (dicocokkan persis).
  List<String> eligibleGroups;

  /// Jika true, semua peserta berhak. Daftar grup kosong tanpa ini berarti tidak ada yang berhak.
  bool openToAll;

  /// Returns a shallow copy of this [EventPrize]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventPrize copyWith({
    int? id,
    int? eventId,
    String? name,
    _i2.PrizeKind? kind,
    int? quantity,
    int? sortOrder,
    List<String>? eligibleGroups,
    bool? openToAll,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventPrize',
      if (id != null) 'id': id,
      'eventId': eventId,
      'name': name,
      'kind': kind.toJson(),
      'quantity': quantity,
      'sortOrder': sortOrder,
      'eligibleGroups': eligibleGroups.toJson(),
      'openToAll': openToAll,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EventPrizeImpl extends EventPrize {
  _EventPrizeImpl({
    int? id,
    required int eventId,
    required String name,
    required _i2.PrizeKind kind,
    required int quantity,
    required int sortOrder,
    required List<String> eligibleGroups,
    required bool openToAll,
  }) : super._(
         id: id,
         eventId: eventId,
         name: name,
         kind: kind,
         quantity: quantity,
         sortOrder: sortOrder,
         eligibleGroups: eligibleGroups,
         openToAll: openToAll,
       );

  /// Returns a shallow copy of this [EventPrize]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventPrize copyWith({
    Object? id = _Undefined,
    int? eventId,
    String? name,
    _i2.PrizeKind? kind,
    int? quantity,
    int? sortOrder,
    List<String>? eligibleGroups,
    bool? openToAll,
  }) {
    return EventPrize(
      id: id is int? ? id : this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      sortOrder: sortOrder ?? this.sortOrder,
      eligibleGroups:
          eligibleGroups ?? this.eligibleGroups.map((e0) => e0).toList(),
      openToAll: openToAll ?? this.openToAll,
    );
  }
}
