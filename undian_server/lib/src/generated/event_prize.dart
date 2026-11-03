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
import 'prize_kind.dart' as _i2;
import 'package:undian_server/src/generated/protocol.dart' as _i3;

/// Hadiah dalam satu acara.
abstract class EventPrize
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  EventPrize._({
    this.id,
    required this.eventId,
    required this.name,
    required this.kind,
    required this.quantity,
    required this.sortOrder,
    required this.eligibleGroups,
    required this.openToAll,
  });

  factory EventPrize({
    int? id,
    required int eventId,
    required String name,
    required _i2.PrizeKind kind,
    required int quantity,
    required int sortOrder,
    required List<String> eligibleGroups,
    required bool openToAll,
  }) = _EventPrizeImpl;

  factory EventPrize.fromJson(Map<String, dynamic> jsonSerialization) {
    return EventPrize(
      id: jsonSerialization['id'] as int?,
      eventId: jsonSerialization['eventId'] as int,
      name: jsonSerialization['name'] as String,
      kind: _i2.PrizeKind.fromJson((jsonSerialization['kind'] as String)),
      quantity: jsonSerialization['quantity'] as int,
      sortOrder: jsonSerialization['sortOrder'] as int,
      eligibleGroups: _i3.Protocol().deserialize<List<String>>(
        jsonSerialization['eligibleGroups'],
      ),
      openToAll: _i1.BoolJsonExtension.fromJson(jsonSerialization['openToAll']),
    );
  }

  static final t = EventPrizeTable();

  static const db = EventPrizeRepository._();

  @override
  int? id;

  int eventId;

  String name;

  _i2.PrizeKind kind;

  /// Jumlah unit hadiah.
  int quantity;

  /// Urutan tampil di rundown acara.
  int sortOrder;

  /// Peserta berhak jika menjadi anggota salah satu grup ini (dicocokkan persis).
  List<String> eligibleGroups;

  /// Jika true, semua peserta berhak. Daftar grup kosong tanpa ini berarti tidak ada yang berhak.
  bool openToAll;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [EventPrize]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EventPrize copyWith({
    int? id,
    int? eventId,
    String? name,
    _i2.PrizeKind? kind,
    int? quantity,
    int? sortOrder,
    List<String>? eligibleGroups,
    bool? openToAll,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EventPrize',
      if (id != null) 'id': id,
      'eventId': eventId,
      'name': name,
      'kind': kind.toJson(),
      'quantity': quantity,
      'sortOrder': sortOrder,
      'eligibleGroups': eligibleGroups.toJson(),
      'openToAll': openToAll,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EventPrize',
      if (id != null) 'id': id,
      'eventId': eventId,
      'name': name,
      'kind': kind.toJson(),
      'quantity': quantity,
      'sortOrder': sortOrder,
      'eligibleGroups': eligibleGroups.toJson(),
      'openToAll': openToAll,
    };
  }

  static EventPrizeInclude include() {
    return EventPrizeInclude._();
  }

  static EventPrizeIncludeList includeList({
    _i1.WhereExpressionBuilder<EventPrizeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EventPrizeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EventPrizeTable>? orderByList,
    EventPrizeInclude? include,
  }) {
    return EventPrizeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EventPrize.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EventPrize.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EventPrizeImpl extends EventPrize {
  _EventPrizeImpl({
    int? id,
    required int eventId,
    required String name,
    required _i2.PrizeKind kind,
    required int quantity,
    required int sortOrder,
    required List<String> eligibleGroups,
    required bool openToAll,
  }) : super._(
         id: id,
         eventId: eventId,
         name: name,
         kind: kind,
         quantity: quantity,
         sortOrder: sortOrder,
         eligibleGroups: eligibleGroups,
         openToAll: openToAll,
       );

  /// Returns a shallow copy of this [EventPrize]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EventPrize copyWith({
    Object? id = _Undefined,
    int? eventId,
    String? name,
    _i2.PrizeKind? kind,
    int? quantity,
    int? sortOrder,
    List<String>? eligibleGroups,
    bool? openToAll,
  }) {
    return EventPrize(
      id: id is int? ? id : this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      quantity: quantity ?? this.quantity,
      sortOrder: sortOrder ?? this.sortOrder,
      eligibleGroups:
          eligibleGroups ?? this.eligibleGroups.map((e0) => e0).toList(),
      openToAll: openToAll ?? this.openToAll,
    );
  }
}

class EventPrizeUpdateTable extends _i1.UpdateTable<EventPrizeTable> {
  EventPrizeUpdateTable(super.table);

  _i1.ColumnValue<int, int> eventId(int value) => _i1.ColumnValue(
    table.eventId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<_i2.PrizeKind, _i2.PrizeKind> kind(_i2.PrizeKind value) =>
      _i1.ColumnValue(
        table.kind,
        value,
      );

  _i1.ColumnValue<int, int> quantity(int value) => _i1.ColumnValue(
    table.quantity,
    value,
  );

  _i1.ColumnValue<int, int> sortOrder(int value) => _i1.ColumnValue(
    table.sortOrder,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> eligibleGroups(
    List<String> value,
  ) => _i1.ColumnValue(
    table.eligibleGroups,
    value,
  );

  _i1.ColumnValue<bool, bool> openToAll(bool value) => _i1.ColumnValue(
    table.openToAll,
    value,
  );
}

class EventPrizeTable extends _i1.Table<int?> {
  EventPrizeTable({super.tableRelation}) : super(tableName: 'prize') {
    updateTable = EventPrizeUpdateTable(this);
    eventId = _i1.ColumnInt(
      'eventId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    kind = _i1.ColumnEnum(
      'kind',
      this,
      _i1.EnumSerialization.byName,
    );
    quantity = _i1.ColumnInt(
      'quantity',
      this,
    );
    sortOrder = _i1.ColumnInt(
      'sortOrder',
      this,
    );
    eligibleGroups = _i1.ColumnSerializable<List<String>>(
      'eligibleGroups',
      this,
    );
    openToAll = _i1.ColumnBool(
      'openToAll',
      this,
    );
  }

  late final EventPrizeUpdateTable updateTable;

  late final _i1.ColumnInt eventId;

  late final _i1.ColumnString name;

  late final _i1.ColumnEnum<_i2.PrizeKind> kind;

  /// Jumlah unit hadiah.
  late final _i1.ColumnInt quantity;

  /// Urutan tampil di rundown acara.
  late final _i1.ColumnInt sortOrder;

  /// Peserta berhak jika menjadi anggota salah satu grup ini (dicocokkan persis).
  late final _i1.ColumnSerializable<List<String>> eligibleGroups;

  /// Jika true, semua peserta berhak. Daftar grup kosong tanpa ini berarti tidak ada yang berhak.
  late final _i1.ColumnBool openToAll;

  @override
  List<_i1.Column> get columns => [
    id,
    eventId,
    name,
    kind,
    quantity,
    sortOrder,
    eligibleGroups,
    openToAll,
  ];
}

class EventPrizeInclude extends _i1.IncludeObject {
  EventPrizeInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => EventPrize.t;
}

class EventPrizeIncludeList extends _i1.IncludeList {
  EventPrizeIncludeList._({
    _i1.WhereExpressionBuilder<EventPrizeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EventPrize.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => EventPrize.t;
}

class EventPrizeRepository {
  const EventPrizeRepository._();

  /// Returns a list of [EventPrize]s matching the given query parameters.
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
  Future<List<EventPrize>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EventPrizeTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EventPrizeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EventPrizeTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EventPrize>(
      where: where?.call(EventPrize.t),
      orderBy: orderBy?.call(EventPrize.t),
      orderByList: orderByList?.call(EventPrize.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EventPrize] matching the given query parameters.
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
  Future<EventPrize?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EventPrizeTable>? where,
    int? offset,
    _i1.OrderByBuilder<EventPrizeTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EventPrizeTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EventPrize>(
      where: where?.call(EventPrize.t),
      orderBy: orderBy?.call(EventPrize.t),
      orderByList: orderByList?.call(EventPrize.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EventPrize] by its [id] or null if no such row exists.
  Future<EventPrize?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EventPrize>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EventPrize]s in the list and returns the inserted rows.
  ///
  /// The returned [EventPrize]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<EventPrize>> insert(
    _i1.DatabaseSession session,
    List<EventPrize> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EventPrize>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EventPrize] and returns the inserted row.
  ///
  /// The returned [EventPrize] will have its `id` field set.
  Future<EventPrize> insertRow(
    _i1.DatabaseSession session,
    EventPrize row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EventPrize>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EventPrize]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EventPrize>> update(
    _i1.DatabaseSession session,
    List<EventPrize> rows, {
    _i1.ColumnSelections<EventPrizeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EventPrize>(
      rows,
      columns: columns?.call(EventPrize.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EventPrize]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EventPrize> updateRow(
    _i1.DatabaseSession session,
    EventPrize row, {
    _i1.ColumnSelections<EventPrizeTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EventPrize>(
      row,
      columns: columns?.call(EventPrize.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EventPrize] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EventPrize?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<EventPrizeUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EventPrize>(
      id,
      columnValues: columnValues(EventPrize.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EventPrize]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EventPrize>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<EventPrizeUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<EventPrizeTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EventPrizeTable>? orderBy,
    _i1.OrderByListBuilder<EventPrizeTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EventPrize>(
      columnValues: columnValues(EventPrize.t.updateTable),
      where: where(EventPrize.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EventPrize.t),
      orderByList: orderByList?.call(EventPrize.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EventPrize]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EventPrize>> delete(
    _i1.DatabaseSession session,
    List<EventPrize> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EventPrize>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EventPrize].
  Future<EventPrize> deleteRow(
    _i1.DatabaseSession session,
    EventPrize row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EventPrize>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EventPrize>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EventPrizeTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EventPrize>(
      where: where(EventPrize.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EventPrizeTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EventPrize>(
      where: where?.call(EventPrize.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EventPrize] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EventPrizeTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EventPrize>(
      where: where(EventPrize.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
