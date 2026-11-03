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

/// Satu acara undian, mis. "HUT 2026" atau "RAT Koperasi 2026".
abstract class DrawEvent implements _i1.SerializableModel {
  DrawEvent._({
    this.id,
    required this.organizationId,
    required this.name,
    this.eventDate,
    required this.allowMultipleWins,
    required this.createdAt,
  });

  factory DrawEvent({
    int? id,
    required int organizationId,
    required String name,
    DateTime? eventDate,
    required bool allowMultipleWins,
    required DateTime createdAt,
  }) = _DrawEventImpl;

  factory DrawEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return DrawEvent(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      name: jsonSerialization['name'] as String,
      eventDate: jsonSerialization['eventDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['eventDate']),
      allowMultipleWins: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['allowMultipleWins'],
      ),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int organizationId;

  String name;

  DateTime? eventDate;

  /// Jika true, pemenang hadiah lain boleh ikut undian hadiah berikutnya.
  bool allowMultipleWins;

  DateTime createdAt;

  /// Returns a shallow copy of this [DrawEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DrawEvent copyWith({
    int? id,
    int? organizationId,
    String? name,
    DateTime? eventDate,
    bool? allowMultipleWins,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DrawEvent',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'name': name,
      if (eventDate != null) 'eventDate': eventDate?.toJson(),
      'allowMultipleWins': allowMultipleWins,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DrawEventImpl extends DrawEvent {
  _DrawEventImpl({
    int? id,
    required int organizationId,
    required String name,
    DateTime? eventDate,
    required bool allowMultipleWins,
    required DateTime createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         name: name,
         eventDate: eventDate,
         allowMultipleWins: allowMultipleWins,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DrawEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DrawEvent copyWith({
    Object? id = _Undefined,
    int? organizationId,
    String? name,
    Object? eventDate = _Undefined,
    bool? allowMultipleWins,
    DateTime? createdAt,
  }) {
    return DrawEvent(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      name: name ?? this.name,
      eventDate: eventDate is DateTime? ? eventDate : this.eventDate,
      allowMultipleWins: allowMultipleWins ?? this.allowMultipleWins,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
