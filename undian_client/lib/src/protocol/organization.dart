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
import 'dart:typed_data' as _i2;

/// Organisasi/perusahaan pemakai aplikasi (tenant). Semua data lain berada di bawahnya.
abstract class Organization implements _i1.SerializableModel {
  Organization._({
    this.id,
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    this.logo,
    required this.createdAt,
  });

  factory Organization({
    int? id,
    required String name,
    required int primaryColor,
    required int accentColor,
    _i2.ByteData? logo,
    required DateTime createdAt,
  }) = _OrganizationImpl;

  factory Organization.fromJson(Map<String, dynamic> jsonSerialization) {
    return Organization(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      primaryColor: jsonSerialization['primaryColor'] as int,
      accentColor: jsonSerialization['accentColor'] as int,
      logo: jsonSerialization['logo'] == null
          ? null
          : _i1.ByteDataJsonExtension.fromJson(jsonSerialization['logo']),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String name;

  /// Warna tema dalam ARGB, mis. 0xFF4F46E5.
  int primaryColor;

  int accentColor;

  /// Logo kecil (PNG/JPG, maks. 300 KB).
  _i2.ByteData? logo;

  DateTime createdAt;

  /// Returns a shallow copy of this [Organization]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Organization copyWith({
    int? id,
    String? name,
    int? primaryColor,
    int? accentColor,
    _i2.ByteData? logo,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Organization',
      if (id != null) 'id': id,
      'name': name,
      'primaryColor': primaryColor,
      'accentColor': accentColor,
      if (logo != null) 'logo': logo?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrganizationImpl extends Organization {
  _OrganizationImpl({
    int? id,
    required String name,
    required int primaryColor,
    required int accentColor,
    _i2.ByteData? logo,
    required DateTime createdAt,
  }) : super._(
         id: id,
         name: name,
         primaryColor: primaryColor,
         accentColor: accentColor,
         logo: logo,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Organization]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Organization copyWith({
    Object? id = _Undefined,
    String? name,
    int? primaryColor,
    int? accentColor,
    Object? logo = _Undefined,
    DateTime? createdAt,
  }) {
    return Organization(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      logo: logo is _i2.ByteData? ? logo : this.logo?.clone(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
