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
import 'package:undian_client/src/protocol/protocol.dart' as _i2;

/// Peserta undian dalam satu acara.
abstract class EventParticipant implements _i1.SerializableModel {
  EventParticipant._({
    this.id,
    required this.eventId,
    required this.nik,
    required this.name,
    required this.area,
    required this.department,
    required this.employmentStatus,
    this.phone,
    required this.points,
    required this.groups,
  });

  factory EventParticipant({
    int? id,
    required int eventId,
    required String nik,
    required String name,
    required String area,
    required String department,
    required String employmentStatus,
    String? phone,
    required int points,
    required List<String> groups,
  }) = _EventParticipantImpl;

  factory EventParticipant.fromJson(Map<String, dynamic> jsonSerialization) {
    return EventParticipant(
      id: jsonSerialization['id'] as int?,
      eventId: jsonSerialization['eventId'] as int,
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int eventId;

  /// Nomor induk karyawan, sekaligus nomor undian. Unik per acara.
  String nik;

  String name;

  String area;

  String department;

  String employmentStatus;

  String? phone;

  /// Bobot peluang: poin N = N tiket undian.
  int points;

  /// Grup yang diikuti, mis. ["Doorprize Bogor", "Grandprize Bogor"].
  List<String> groups;

  /// Returns a shallow copy of this [EventParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventParticipant copyWith({
    int? id,
    int? eventId,
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
      '__className__': 'EventParticipant',
      if (id != null) 'id': id,
      'eventId': eventId,
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

class _EventParticipantImpl extends EventParticipant {
  _EventParticipantImpl({
    int? id,
    required int eventId,
    required String nik,
    required String name,
    required String area,
    required String department,
    required String employmentStatus,
    String? phone,
    required int points,
    required List<String> groups,
  }) : super._(
         id: id,
         eventId: eventId,
         nik: nik,
         name: name,
         area: area,
         department: department,
         employmentStatus: employmentStatus,
         phone: phone,
         points: points,
         groups: groups,
       );

  /// Returns a shallow copy of this [EventParticipant]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventParticipant copyWith({
    Object? id = _Undefined,
    int? eventId,
    String? nik,
    String? name,
    String? area,
    String? department,
    String? employmentStatus,
    Object? phone = _Undefined,
    int? points,
    List<String>? groups,
  }) {
    return EventParticipant(
      id: id is int? ? id : this.id,
      eventId: eventId ?? this.eventId,
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
