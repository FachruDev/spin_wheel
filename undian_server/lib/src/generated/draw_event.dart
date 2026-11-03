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

/// Satu acara undian, mis. "HUT 2026" atau "RAT Koperasi 2026".
abstract class DrawEvent
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = DrawEventTable();

  static const db = DrawEventRepository._();

  @override
  int? id;

  int organizationId;

  String name;

  DateTime? eventDate;

  /// Jika true, pemenang hadiah lain boleh ikut undian hadiah berikutnya.
  bool allowMultipleWins;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static DrawEventInclude include() {
    return DrawEventInclude._();
  }

  static DrawEventIncludeList includeList({
    _i1.WhereExpressionBuilder<DrawEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DrawEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DrawEventTable>? orderByList,
    DrawEventInclude? include,
  }) {
    return DrawEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DrawEvent.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DrawEvent.t),
      include: include,
    );
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

class DrawEventUpdateTable extends _i1.UpdateTable<DrawEventTable> {
  DrawEventUpdateTable(super.table);

  _i1.ColumnValue<int, int> organizationId(int value) => _i1.ColumnValue(
    table.organizationId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> eventDate(DateTime? value) =>
      _i1.ColumnValue(
        table.eventDate,
        value,
      );

  _i1.ColumnValue<bool, bool> allowMultipleWins(bool value) => _i1.ColumnValue(
    table.allowMultipleWins,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class DrawEventTable extends _i1.Table<int?> {
  DrawEventTable({super.tableRelation}) : super(tableName: 'draw_event') {
    updateTable = DrawEventUpdateTable(this);
    organizationId = _i1.ColumnInt(
      'organizationId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    eventDate = _i1.ColumnDateTime(
      'eventDate',
      this,
    );
    allowMultipleWins = _i1.ColumnBool(
      'allowMultipleWins',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final DrawEventUpdateTable updateTable;

  late final _i1.ColumnInt organizationId;

  late final _i1.ColumnString name;

  late final _i1.ColumnDateTime eventDate;

  /// Jika true, pemenang hadiah lain boleh ikut undian hadiah berikutnya.
  late final _i1.ColumnBool allowMultipleWins;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    organizationId,
    name,
    eventDate,
    allowMultipleWins,
    createdAt,
  ];
}

class DrawEventInclude extends _i1.IncludeObject {
  DrawEventInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DrawEvent.t;
}

class DrawEventIncludeList extends _i1.IncludeList {
  DrawEventIncludeList._({
    _i1.WhereExpressionBuilder<DrawEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DrawEvent.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DrawEvent.t;
}

class DrawEventRepository {
  const DrawEventRepository._();

  /// Returns a list of [DrawEvent]s matching the given query parameters.
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
  Future<List<DrawEvent>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DrawEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DrawEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DrawEventTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DrawEvent>(
      where: where?.call(DrawEvent.t),
      orderBy: orderBy?.call(DrawEvent.t),
      orderByList: orderByList?.call(DrawEvent.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DrawEvent] matching the given query parameters.
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
  Future<DrawEvent?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DrawEventTable>? where,
    int? offset,
    _i1.OrderByBuilder<DrawEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DrawEventTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DrawEvent>(
      where: where?.call(DrawEvent.t),
      orderBy: orderBy?.call(DrawEvent.t),
      orderByList: orderByList?.call(DrawEvent.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DrawEvent] by its [id] or null if no such row exists.
  Future<DrawEvent?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DrawEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DrawEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [DrawEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<DrawEvent>> insert(
    _i1.DatabaseSession session,
    List<DrawEvent> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<DrawEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [DrawEvent] and returns the inserted row.
  ///
  /// The returned [DrawEvent] will have its `id` field set.
  Future<DrawEvent> insertRow(
    _i1.DatabaseSession session,
    DrawEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DrawEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DrawEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DrawEvent>> update(
    _i1.DatabaseSession session,
    List<DrawEvent> rows, {
    _i1.ColumnSelections<DrawEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DrawEvent>(
      rows,
      columns: columns?.call(DrawEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DrawEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DrawEvent> updateRow(
    _i1.DatabaseSession session,
    DrawEvent row, {
    _i1.ColumnSelections<DrawEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DrawEvent>(
      row,
      columns: columns?.call(DrawEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DrawEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DrawEvent?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<DrawEventUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DrawEvent>(
      id,
      columnValues: columnValues(DrawEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DrawEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DrawEvent>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<DrawEventUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DrawEventTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DrawEventTable>? orderBy,
    _i1.OrderByListBuilder<DrawEventTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DrawEvent>(
      columnValues: columnValues(DrawEvent.t.updateTable),
      where: where(DrawEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DrawEvent.t),
      orderByList: orderByList?.call(DrawEvent.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DrawEvent]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DrawEvent>> delete(
    _i1.DatabaseSession session,
    List<DrawEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DrawEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DrawEvent].
  Future<DrawEvent> deleteRow(
    _i1.DatabaseSession session,
    DrawEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DrawEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DrawEvent>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DrawEventTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DrawEvent>(
      where: where(DrawEvent.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DrawEventTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DrawEvent>(
      where: where?.call(DrawEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DrawEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DrawEventTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DrawEvent>(
      where: where(DrawEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
