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

/// Catatan setiap aksi penting (undi, ubah status, import) untuk pertanggungjawaban.
abstract class AuditLog implements _i1.SerializableModel {
  AuditLog._({
    this.id,
    required this.organizationId,
    this.eventId,
    required this.authUserId,
    required this.action,
    required this.detail,
    required this.createdAt,
  });

  factory AuditLog({
    int? id,
    required int organizationId,
    int? eventId,
    required _i1.UuidValue authUserId,
    required String action,
    required String detail,
    required DateTime createdAt,
  }) = _AuditLogImpl;

  factory AuditLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditLog(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      eventId: jsonSerialization['eventId'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      action: jsonSerialization['action'] as String,
      detail: jsonSerialization['detail'] as String,
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

  int? eventId;

  _i1.UuidValue authUserId;

  /// Kode aksi, mis. "draw", "winner.forfeit", "participant.import".
  String action;

  String detail;

  DateTime createdAt;

  /// Returns a shallow copy of this [AuditLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AuditLog copyWith({
    int? id,
    int? organizationId,
    int? eventId,
    _i1.UuidValue? authUserId,
    String? action,
    String? detail,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditLog',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      if (eventId != null) 'eventId': eventId,
      'authUserId': authUserId.toJson(),
      'action': action,
      'detail': detail,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditLogImpl extends AuditLog {
  _AuditLogImpl({
    int? id,
    required int organizationId,
    int? eventId,
    required _i1.UuidValue authUserId,
    required String action,
    required String detail,
    required DateTime createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         eventId: eventId,
         authUserId: authUserId,
         action: action,
         detail: detail,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AuditLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AuditLog copyWith({
    Object? id = _Undefined,
    int? organizationId,
    Object? eventId = _Undefined,
    _i1.UuidValue? authUserId,
    String? action,
    String? detail,
    DateTime? createdAt,
  }) {
    return AuditLog(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      eventId: eventId is int? ? eventId : this.eventId,
      authUserId: authUserId ?? this.authUserId,
      action: action ?? this.action,
      detail: detail ?? this.detail,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
