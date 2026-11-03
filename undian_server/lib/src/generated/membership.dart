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
import 'member_role.dart' as _i2;

/// Keanggotaan pengguna (akun login) di sebuah organisasi.
abstract class Membership
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = MembershipTable();

  static const db = MembershipRepository._();

  @override
  int? id;

  int organizationId;

  /// ID pengguna dari modul auth Serverpod.
  _i1.UuidValue authUserId;

  _i2.MemberRole role;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Membership',
      if (id != null) 'id': id,
      'organizationId': organizationId,
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static MembershipInclude include() {
    return MembershipInclude._();
  }

  static MembershipIncludeList includeList({
    _i1.WhereExpressionBuilder<MembershipTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MembershipTable>? orderByList,
    MembershipInclude? include,
  }) {
    return MembershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Membership.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Membership.t),
      include: include,
    );
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

class MembershipUpdateTable extends _i1.UpdateTable<MembershipTable> {
  MembershipUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<_i2.MemberRole, _i2.MemberRole> role(_i2.MemberRole value) =>
      _i1.ColumnValue(
        table.role,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class MembershipTable extends _i1.Table<int?> {
  MembershipTable({super.tableRelation}) : super(tableName: 'membership') {
    updateTable = MembershipUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MembershipUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  /// ID pengguna dari modul auth Serverpod.
  late final _i1.ColumnUuid authUserId;

  late final _i1.ColumnEnum<_i2.MemberRole> role;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    authUserId,
    role,
    createdAt,
  ];
}

class MembershipInclude extends _i1.IncludeObject {
  MembershipInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Membership.t;
}

class MembershipIncludeList extends _i1.IncludeList {
  MembershipIncludeList._({
    _i1.WhereExpressionBuilder<MembershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Membership.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Membership.t;
}

class MembershipRepository {
  const MembershipRepository._();

  /// Returns a list of [Membership]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Membership>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MembershipTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MembershipTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Membership>(
      where: where?.call(Membership.t),
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Membership] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Membership?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MembershipTable>? where,
    int? offset,
    _i1.OrderByBuilder<MembershipTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MembershipTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Membership>(
      where: where?.call(Membership.t),
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Membership] by its [id] or null if no such row exists.
  Future<Membership?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Membership>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Membership]s in the list and returns the inserted rows.
  ///
  /// The returned [Membership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Membership>> insert(
    _i1.DatabaseSession session,
    List<Membership> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Membership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Membership] and returns the inserted row.
  ///
  /// The returned [Membership] will have its `id` field set.
  Future<Membership> insertRow(
    _i1.DatabaseSession session,
    Membership row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Membership>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Membership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Membership>> update(
    _i1.DatabaseSession session,
    List<Membership> rows, {
    _i1.ColumnSelections<MembershipTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Membership>(
      rows,
      columns: columns?.call(Membership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Membership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Membership> updateRow(
    _i1.DatabaseSession session,
    Membership row, {
    _i1.ColumnSelections<MembershipTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Membership>(
      row,
      columns: columns?.call(Membership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Membership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Membership?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MembershipUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Membership>(
      id,
      columnValues: columnValues(Membership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Membership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Membership>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MembershipUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MembershipTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MembershipTable>? orderBy,
    _i1.OrderByListBuilder<MembershipTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Membership>(
      columnValues: columnValues(Membership.t.updateTable),
      where: where(Membership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Membership]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Membership>> delete(
    _i1.DatabaseSession session,
    List<Membership> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Membership>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Membership].
  Future<Membership> deleteRow(
    _i1.DatabaseSession session,
    Membership row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Membership>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Membership>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MembershipTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Membership>(
      where: where(Membership.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MembershipTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Membership>(
      where: where?.call(Membership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Membership] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MembershipTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Membership>(
      where: where(Membership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
