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
import 'audit_log.dart' as _i2;
import 'draw_event.dart' as _i3;
import 'draw_result.dart' as _i4;
import 'event_participant.dart' as _i5;
import 'event_prize.dart' as _i6;
import 'import_result.dart' as _i7;
import 'member_role.dart' as _i8;
import 'membership.dart' as _i9;
import 'my_organization.dart' as _i10;
import 'organization.dart' as _i11;
import 'participant_input.dart' as _i12;
import 'prize_kind.dart' as _i13;
import 'prize_winner.dart' as _i14;
import 'undian_exception.dart' as _i15;
import 'winner_status.dart' as _i16;
import 'package:undian_client/src/protocol/prize_winner.dart' as _i17;
import 'package:undian_client/src/protocol/draw_event.dart' as _i18;
import 'package:undian_client/src/protocol/my_organization.dart' as _i19;
import 'package:undian_client/src/protocol/event_participant.dart' as _i20;
import 'package:undian_client/src/protocol/participant_input.dart' as _i21;
import 'package:undian_client/src/protocol/event_prize.dart' as _i22;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i23;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i24;
export 'audit_log.dart';
export 'draw_event.dart';
export 'draw_result.dart';
export 'event_participant.dart';
export 'event_prize.dart';
export 'import_result.dart';
export 'member_role.dart';
export 'membership.dart';
export 'my_organization.dart';
export 'organization.dart';
export 'participant_input.dart';
export 'prize_kind.dart';
export 'prize_winner.dart';
export 'undian_exception.dart';
export 'winner_status.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.AuditLog) {
      return _i2.AuditLog.fromJson(data) as T;
    }
    if (t == _i3.DrawEvent) {
      return _i3.DrawEvent.fromJson(data) as T;
    }
    if (t == _i4.DrawResult) {
      return _i4.DrawResult.fromJson(data) as T;
    }
    if (t == _i5.EventParticipant) {
      return _i5.EventParticipant.fromJson(data) as T;
    }
    if (t == _i6.EventPrize) {
      return _i6.EventPrize.fromJson(data) as T;
    }
    if (t == _i7.ImportResult) {
      return _i7.ImportResult.fromJson(data) as T;
    }
    if (t == _i8.MemberRole) {
      return _i8.MemberRole.fromJson(data) as T;
    }
    if (t == _i9.Membership) {
      return _i9.Membership.fromJson(data) as T;
    }
    if (t == _i10.MyOrganization) {
      return _i10.MyOrganization.fromJson(data) as T;
    }
    if (t == _i11.Organization) {
      return _i11.Organization.fromJson(data) as T;
    }
    if (t == _i12.ParticipantInput) {
      return _i12.ParticipantInput.fromJson(data) as T;
    }
    if (t == _i13.PrizeKind) {
      return _i13.PrizeKind.fromJson(data) as T;
    }
    if (t == _i14.PrizeWinner) {
      return _i14.PrizeWinner.fromJson(data) as T;
    }
    if (t == _i15.UndianException) {
      return _i15.UndianException.fromJson(data) as T;
    }
    if (t == _i16.WinnerStatus) {
      return _i16.WinnerStatus.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AuditLog?>()) {
      return (data != null ? _i2.AuditLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DrawEvent?>()) {
      return (data != null ? _i3.DrawEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DrawResult?>()) {
      return (data != null ? _i4.DrawResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.EventParticipant?>()) {
      return (data != null ? _i5.EventParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.EventPrize?>()) {
      return (data != null ? _i6.EventPrize.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.ImportResult?>()) {
      return (data != null ? _i7.ImportResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MemberRole?>()) {
      return (data != null ? _i8.MemberRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Membership?>()) {
      return (data != null ? _i9.Membership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.MyOrganization?>()) {
      return (data != null ? _i10.MyOrganization.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.Organization?>()) {
      return (data != null ? _i11.Organization.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.ParticipantInput?>()) {
      return (data != null ? _i12.ParticipantInput.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.PrizeKind?>()) {
      return (data != null ? _i13.PrizeKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.PrizeWinner?>()) {
      return (data != null ? _i14.PrizeWinner.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.UndianException?>()) {
      return (data != null ? _i15.UndianException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.WinnerStatus?>()) {
      return (data != null ? _i16.WinnerStatus.fromJson(data) : null) as T;
    }
    if (t == List<_i5.EventParticipant>) {
      return (data as List)
              .map((e) => deserialize<_i5.EventParticipant>(e))
              .toList()
          as T;
    }
    if (t == List<_i14.PrizeWinner>) {
      return (data as List)
              .map((e) => deserialize<_i14.PrizeWinner>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i17.PrizeWinner>) {
      return (data as List)
              .map((e) => deserialize<_i17.PrizeWinner>(e))
              .toList()
          as T;
    }
    if (t == List<_i18.DrawEvent>) {
      return (data as List).map((e) => deserialize<_i18.DrawEvent>(e)).toList()
          as T;
    }
    if (t == List<_i19.MyOrganization>) {
      return (data as List)
              .map((e) => deserialize<_i19.MyOrganization>(e))
              .toList()
          as T;
    }
    if (t == List<_i20.EventParticipant>) {
      return (data as List)
              .map((e) => deserialize<_i20.EventParticipant>(e))
              .toList()
          as T;
    }
    if (t == List<_i21.ParticipantInput>) {
      return (data as List)
              .map((e) => deserialize<_i21.ParticipantInput>(e))
              .toList()
          as T;
    }
    if (t == List<_i22.EventPrize>) {
      return (data as List).map((e) => deserialize<_i22.EventPrize>(e)).toList()
          as T;
    }
    try {
      return _i23.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i24.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AuditLog => 'AuditLog',
      _i3.DrawEvent => 'DrawEvent',
      _i4.DrawResult => 'DrawResult',
      _i5.EventParticipant => 'EventParticipant',
      _i6.EventPrize => 'EventPrize',
      _i7.ImportResult => 'ImportResult',
      _i8.MemberRole => 'MemberRole',
      _i9.Membership => 'Membership',
      _i10.MyOrganization => 'MyOrganization',
      _i11.Organization => 'Organization',
      _i12.ParticipantInput => 'ParticipantInput',
      _i13.PrizeKind => 'PrizeKind',
      _i14.PrizeWinner => 'PrizeWinner',
      _i15.UndianException => 'UndianException',
      _i16.WinnerStatus => 'WinnerStatus',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('undian.', '');
    }

    switch (data) {
      case _i2.AuditLog():
        return 'AuditLog';
      case _i3.DrawEvent():
        return 'DrawEvent';
      case _i4.DrawResult():
        return 'DrawResult';
      case _i5.EventParticipant():
        return 'EventParticipant';
      case _i6.EventPrize():
        return 'EventPrize';
      case _i7.ImportResult():
        return 'ImportResult';
      case _i8.MemberRole():
        return 'MemberRole';
      case _i9.Membership():
        return 'Membership';
      case _i10.MyOrganization():
        return 'MyOrganization';
      case _i11.Organization():
        return 'Organization';
      case _i12.ParticipantInput():
        return 'ParticipantInput';
      case _i13.PrizeKind():
        return 'PrizeKind';
      case _i14.PrizeWinner():
        return 'PrizeWinner';
      case _i15.UndianException():
        return 'UndianException';
      case _i16.WinnerStatus():
        return 'WinnerStatus';
    }
    className = _i23.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i24.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AuditLog') {
      return deserialize<_i2.AuditLog>(data['data']);
    }
    if (dataClassName == 'DrawEvent') {
      return deserialize<_i3.DrawEvent>(data['data']);
    }
    if (dataClassName == 'DrawResult') {
      return deserialize<_i4.DrawResult>(data['data']);
    }
    if (dataClassName == 'EventParticipant') {
      return deserialize<_i5.EventParticipant>(data['data']);
    }
    if (dataClassName == 'EventPrize') {
      return deserialize<_i6.EventPrize>(data['data']);
    }
    if (dataClassName == 'ImportResult') {
      return deserialize<_i7.ImportResult>(data['data']);
    }
    if (dataClassName == 'MemberRole') {
      return deserialize<_i8.MemberRole>(data['data']);
    }
    if (dataClassName == 'Membership') {
      return deserialize<_i9.Membership>(data['data']);
    }
    if (dataClassName == 'MyOrganization') {
      return deserialize<_i10.MyOrganization>(data['data']);
    }
    if (dataClassName == 'Organization') {
      return deserialize<_i11.Organization>(data['data']);
    }
    if (dataClassName == 'ParticipantInput') {
      return deserialize<_i12.ParticipantInput>(data['data']);
    }
    if (dataClassName == 'PrizeKind') {
      return deserialize<_i13.PrizeKind>(data['data']);
    }
    if (dataClassName == 'PrizeWinner') {
      return deserialize<_i14.PrizeWinner>(data['data']);
    }
    if (dataClassName == 'UndianException') {
      return deserialize<_i15.UndianException>(data['data']);
    }
    if (dataClassName == 'WinnerStatus') {
      return deserialize<_i16.WinnerStatus>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i23.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i24.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i23.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i24.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
