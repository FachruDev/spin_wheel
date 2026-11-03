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

/// Ringkasan hasil import peserta.
abstract class ImportResult implements _i1.SerializableModel {
  ImportResult._({
    required this.inserted,
    required this.updated,
    required this.rejected,
  });

  factory ImportResult({
    required int inserted,
    required int updated,
    required List<String> rejected,
  }) = _ImportResultImpl;

  factory ImportResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ImportResult(
      inserted: jsonSerialization['inserted'] as int,
      updated: jsonSerialization['updated'] as int,
      rejected: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['rejected'],
      ),
    );
  }

  int inserted;

  int updated;

  /// Baris yang ditolak beserta alasannya, mis. "Baris 12: NIK kosong".
  List<String> rejected;

  /// Returns a shallow copy of this [ImportResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ImportResult copyWith({
    int? inserted,
    int? updated,
    List<String>? rejected,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ImportResult',
      'inserted': inserted,
      'updated': updated,
      'rejected': rejected.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ImportResultImpl extends ImportResult {
  _ImportResultImpl({
    required int inserted,
    required int updated,
    required List<String> rejected,
  }) : super._(
         inserted: inserted,
         updated: updated,
         rejected: rejected,
       );

  /// Returns a shallow copy of this [ImportResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ImportResult copyWith({
    int? inserted,
    int? updated,
    List<String>? rejected,
  }) {
    return ImportResult(
      inserted: inserted ?? this.inserted,
      updated: updated ?? this.updated,
      rejected: rejected ?? this.rejected.map((e0) => e0).toList(),
    );
  }
}
