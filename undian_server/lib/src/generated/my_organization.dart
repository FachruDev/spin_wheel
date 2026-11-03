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
import 'organization.dart' as _i2;
import 'member_role.dart' as _i3;
import 'package:undian_server/src/generated/protocol.dart' as _i4;

/// Organisasi milik pengguna yang sedang login, beserta perannya.
abstract class MyOrganization
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MyOrganization._({
    required this.organization,
    required this.role,
  });

  factory MyOrganization({
    required _i2.Organization organization,
    required _i3.MemberRole role,
  }) = _MyOrganizationImpl;

  factory MyOrganization.fromJson(Map<String, dynamic> jsonSerialization) {
    return MyOrganization(
      organization: _i4.Protocol().deserialize<_i2.Organization>(
        jsonSerialization['organization'],
      ),
      role: _i3.MemberRole.fromJson((jsonSerialization['role'] as String)),
    );
  }

  _i2.Organization organization;

  _i3.MemberRole role;

  /// Returns a shallow copy of this [MyOrganization]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MyOrganization copyWith({
    _i2.Organization? organization,
    _i3.MemberRole? role,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MyOrganization',
      'organization': organization.toJson(),
      'role': role.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MyOrganization',
      'organization': organization.toJsonForProtocol(),
      'role': role.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MyOrganizationImpl extends MyOrganization {
  _MyOrganizationImpl({
    required _i2.Organization organization,
    required _i3.MemberRole role,
  }) : super._(
         organization: organization,
         role: role,
       );

  /// Returns a shallow copy of this [MyOrganization]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MyOrganization copyWith({
    _i2.Organization? organization,
    _i3.MemberRole? role,
  }) {
    return MyOrganization(
      organization: organization ?? this.organization.copyWith(),
      role: role ?? this.role,
    );
  }
}
