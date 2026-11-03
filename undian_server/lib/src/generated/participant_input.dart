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
import 'package:undian_server/src/generated/protocol.dart' as _i2;

/// Satu baris peserta dari file Excel yang sudah dipetakan kolomnya di aplikasi.
abstract class ParticipantInput
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  ParticipantInput._({
    required this.nik,
    required this.name,
    required this.area,
    required this.department,
    required this.employmentStatus,
    this.phone,
    required this.points,
    required this.groups,
  });

  factory ParticipantInput({
    required String nik,
    required String name,
    required String area,
    required String department,
    required String employmentStatus,
    String? phone,
    required int points,
    required List<String> groups,
  }) = _ParticipantInputImpl;

  factory ParticipantInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return ParticipantInput(
      nik: jsonSerialization['nik'] as String,
      name: jsonSerialization['name'] as String,
      area: jsonSerialization['area'] as String,
      department: jsonSerialization['department'] as String,
      employmentStatus: jsonSerialization['employmentStatus'] as String,
      phone: jsonSerialization['phone'] as String?,
      points: jsonSerialization['points'] as int,
      groups: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['groups'],
      ),
    );
  }

  String nik;

  String name;

  String area;

  String department;

  String employmentStatus;

  String? phone;

  /// Kosong di Excel dianggap 1.
  int points;

  List<String> groups;

  /// Returns a shallow copy of this [ParticipantInput]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ParticipantInput copyWith({
    String? nik,
    String? name,
    String? area,
    String? department,
    String? employmentStatus,
    String? phone,
    int? points,
    List<String>? groups,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ParticipantInput',
      'nik': nik,
      'name': name,
      'area': area,
      'department': department,
      'employmentStatus': employmentStatus,
      if (phone != null) 'phone': phone,
      'points': points,
      'groups': groups.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ParticipantInput',
      'nik': nik,
      'name': name,
      'area': area,
      'department': department,
      'employmentStatus': employmentStatus,
      if (phone != null) 'phone': phone,
      'points': points,
      'groups': groups.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ParticipantInputImpl extends ParticipantInput {
  _ParticipantInputImpl({
    required String nik,
    required String name,
    required String area,
    required String department,
    required String employmentStatus,
    String? phone,
    required int points,
    required List<String> groups,
  }) : super._(
         nik: nik,
         name: name,
         area: area,
         department: department,
         employmentStatus: employmentStatus,
         phone: phone,
         points: points,
         groups: groups,
       );

  /// Returns a shallow copy of this [ParticipantInput]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ParticipantInput copyWith({
    String? nik,
    String? name,
    String? area,
    String? department,
    String? employmentStatus,
    Object? phone = _Undefined,
    int? points,
    List<String>? groups,
  }) {
    return ParticipantInput(
      nik: nik ?? this.nik,
      name: name ?? this.name,
      area: area ?? this.area,
      department: department ?? this.department,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      phone: phone is String? ? phone : this.phone,
      points: points ?? this.points,
      groups: groups ?? this.groups.map((e0) => e0).toList(),
    );
  }
}
