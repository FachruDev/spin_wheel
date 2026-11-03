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
import 'member_role.dart' as _i2;

/// Keanggotaan pengguna (akun login) di sebuah organisasi.
abstract class Membership implements _i1.SerializableModel {
  Membership._({
    this.id,
    required this.organizationId,
    required this.authUserId,
    required this.role,
    required this.createdAt,
  });

  factory Membership({
    int? id,
    required int organizationId,
    required _i1.UuidValue authUserId,
    required _i2.MemberRole role,
    required DateTime createdAt,
  }) = _MembershipImpl;

  factory Membership.fromJson(Map<String, dynamic> jsonSerialization) {
    return Membership(
      id: jsonSerialization['id'] as int?,
      organizationId: jsonSerialization['organizationId'] as int,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      role: _i2.MemberRole.fromJson((jsonSerialization['role'] as String)),
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

  /// ID pengguna dari modul auth Serverpod.
  _i1.UuidValue authUserId;

  _i2.MemberRole role;

  DateTime createdAt;

  /// Returns a shallow copy of this [Membership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Membership copyWith({
    int? id,
    int? organizationId,
    _i1.UuidValue? authUserId,
    _i2.MemberRole? role,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Membership',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MembershipImpl extends Membership {
  _MembershipImpl({
    int? id,
    required int organizationId,
    required _i1.UuidValue authUserId,
    required _i2.MemberRole role,
    required DateTime createdAt,
  }) : super._(
         id: id,
         organizationId: organizationId,
         authUserId: authUserId,
         role: role,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Membership]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Membership copyWith({
    Object? id = _Undefined,
    int? organizationId,
    _i1.UuidValue? authUserId,
    _i2.MemberRole? role,
    DateTime? createdAt,
  }) {
    return Membership(
      id: id is int? ? id : this.id,
      organizationId: organizationId ?? this.organizationId,
      authUserId: authUserId ?? this.authUserId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
