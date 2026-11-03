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
import 'winner_status.dart' as _i2;

/// Hasil undian: satu peserta memenangkan satu unit hadiah.
abstract class PrizeWinner
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PrizeWinner._({
    this.id,
    required this.eventId,
    required this.prizeId,
    required this.participantId,
    required this.roundNo,
    required this.status,
    required this.drawnAt,
    required this.drawnBy,
    this.note,
  });

  factory PrizeWinner({
    int? id,
    required int eventId,
    required int prizeId,
    required int participantId,
    required int roundNo,
    required _i2.WinnerStatus status,
    required DateTime drawnAt,
    required _i1.UuidValue drawnBy,
    String? note,
  }) = _PrizeWinnerImpl;

  factory PrizeWinner.fromJson(Map<String, dynamic> jsonSerialization) {
    return PrizeWinner(
      id: jsonSerialization['id'] as int?,
      eventId: jsonSerialization['eventId'] as int,
      prizeId: jsonSerialization['prizeId'] as int,
      participantId: jsonSerialization['participantId'] as int,
      roundNo: jsonSerialization['roundNo'] as int,
      status: _i2.WinnerStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      drawnAt: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['drawnAt']),
      drawnBy: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['drawnBy'],
      ),
      note: jsonSerialization['note'] as String?,
    );
  }

  static final t = PrizeWinnerTable();

  static const db = PrizeWinnerRepository._();

  @override
  int? id;

  int eventId;

  int prizeId;

  int participantId;

  /// Nomor putaran undian dalam acara (1, 2, 3, ...).
  int roundNo;

  _i2.WinnerStatus status;

  DateTime drawnAt;

  /// Operator yang menjalankan undian.
  _i1.UuidValue drawnBy;

  /// Alasan perubahan status, mis. "Tidak hadir saat dipanggil".
  String? note;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PrizeWinner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PrizeWinner copyWith({
    int? id,
    int? eventId,
    int? prizeId,
    int? participantId,
    int? roundNo,
    _i2.WinnerStatus? status,
    DateTime? drawnAt,
    _i1.UuidValue? drawnBy,
    String? note,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PrizeWinner',
      if (id != null) 'id': id,
      'eventId': eventId,
      'prizeId': prizeId,
      'participantId': participantId,
      'roundNo': roundNo,
      'status': status.toJson(),
      'drawnAt': drawnAt.toJson(),
      'drawnBy': drawnBy.toJson(),
      if (note != null) 'note': note,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PrizeWinner',
      if (id != null) 'id': id,
      'eventId': eventId,
      'prizeId': prizeId,
      'participantId': participantId,
      'roundNo': roundNo,
      'status': status.toJson(),
      'drawnAt': drawnAt.toJson(),
      'drawnBy': drawnBy.toJson(),
      if (note != null) 'note': note,
    };
  }

  static PrizeWinnerInclude include() {
    return PrizeWinnerInclude._();
  }

  static PrizeWinnerIncludeList includeList({
    _i1.WhereExpressionBuilder<PrizeWinnerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrizeWinnerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrizeWinnerTable>? orderByList,
    PrizeWinnerInclude? include,
  }) {
    return PrizeWinnerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PrizeWinner.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PrizeWinner.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PrizeWinnerImpl extends PrizeWinner {
  _PrizeWinnerImpl({
    int? id,
    required int eventId,
    required int prizeId,
    required int participantId,
    required int roundNo,
    required _i2.WinnerStatus status,
    required DateTime drawnAt,
    required _i1.UuidValue drawnBy,
    String? note,
  }) : super._(
         id: id,
         eventId: eventId,
         prizeId: prizeId,
         participantId: participantId,
         roundNo: roundNo,
         status: status,
         drawnAt: drawnAt,
         drawnBy: drawnBy,
         note: note,
       );

  /// Returns a shallow copy of this [PrizeWinner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PrizeWinner copyWith({
    Object? id = _Undefined,
    int? eventId,
    int? prizeId,
    int? participantId,
    int? roundNo,
    _i2.WinnerStatus? status,
    DateTime? drawnAt,
    _i1.UuidValue? drawnBy,
    Object? note = _Undefined,
  }) {
    return PrizeWinner(
      id: id is int? ? id : this.id,
      eventId: eventId ?? this.eventId,
      prizeId: prizeId ?? this.prizeId,
      participantId: participantId ?? this.participantId,
      roundNo: roundNo ?? this.roundNo,
      status: status ?? this.status,
      drawnAt: drawnAt ?? this.drawnAt,
      drawnBy: drawnBy ?? this.drawnBy,
      note: note is String? ? note : this.note,
    );
  }
}

class PrizeWinnerUpdateTable extends _i1.UpdateTable<PrizeWinnerTable> {
  PrizeWinnerUpdateTable(super.table);

  _i1.ColumnValue<int, int> eventId(int value) => _i1.ColumnValue(
    table.eventId,
    value,
  );

  _i1.ColumnValue<int, int> prizeId(int value) => _i1.ColumnValue(
    table.prizeId,
    value,
  );

  _i1.ColumnValue<int, int> participantId(int value) => _i1.ColumnValue(
    table.participantId,
    value,
  );

  _i1.ColumnValue<int, int> roundNo(int value) => _i1.ColumnValue(
    table.roundNo,
    value,
  );

  _i1.ColumnValue<_i2.WinnerStatus, _i2.WinnerStatus> status(
    _i2.WinnerStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> drawnAt(DateTime value) =>
      _i1.ColumnValue(
        table.drawnAt,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> drawnBy(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.drawnBy,
        value,
      );

  _i1.ColumnValue<String, String> note(String? value) => _i1.ColumnValue(
    table.note,
    value,
  );
}

class PrizeWinnerTable extends _i1.Table<int?> {
  PrizeWinnerTable({super.tableRelation}) : super(tableName: 'winner') {
    updateTable = PrizeWinnerUpdateTable(this);
    eventId = _i1.ColumnInt(
      'eventId',
      this,
    );
    prizeId = _i1.ColumnInt(
      'prizeId',
      this,
    );
    participantId = _i1.ColumnInt(
      'participantId',
      this,
    );
    roundNo = _i1.ColumnInt(
      'roundNo',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
    );
    drawnAt = _i1.ColumnDateTime(
      'drawnAt',
      this,
    );
    drawnBy = _i1.ColumnUuid(
      'drawnBy',
      this,
    );
    note = _i1.ColumnString(
      'note',
      this,
    );
  }

  late final PrizeWinnerUpdateTable updateTable;

  late final _i1.ColumnInt eventId;

  late final _i1.ColumnInt prizeId;

  late final _i1.ColumnInt participantId;

  /// Nomor putaran undian dalam acara (1, 2, 3, ...).
  late final _i1.ColumnInt roundNo;

  late final _i1.ColumnEnum<_i2.WinnerStatus> status;

  late final _i1.ColumnDateTime drawnAt;

  /// Operator yang menjalankan undian.
  late final _i1.ColumnUuid drawnBy;

  /// Alasan perubahan status, mis. "Tidak hadir saat dipanggil".
  late final _i1.ColumnString note;

  @override
  List<_i1.Column> get columns => [
    id,
    eventId,
    prizeId,
    participantId,
    roundNo,
    status,
    drawnAt,
    drawnBy,
    note,
  ];
}

class PrizeWinnerInclude extends _i1.IncludeObject {
  PrizeWinnerInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PrizeWinner.t;
}

class PrizeWinnerIncludeList extends _i1.IncludeList {
  PrizeWinnerIncludeList._({
    _i1.WhereExpressionBuilder<PrizeWinnerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PrizeWinner.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PrizeWinner.t;
}

class PrizeWinnerRepository {
  const PrizeWinnerRepository._();

  /// Returns a list of [PrizeWinner]s matching the given query parameters.
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
  Future<List<PrizeWinner>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrizeWinnerTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrizeWinnerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrizeWinnerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PrizeWinner>(
      where: where?.call(PrizeWinner.t),
      orderBy: orderBy?.call(PrizeWinner.t),
      orderByList: orderByList?.call(PrizeWinner.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PrizeWinner] matching the given query parameters.
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
  Future<PrizeWinner?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrizeWinnerTable>? where,
    int? offset,
    _i1.OrderByBuilder<PrizeWinnerTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PrizeWinnerTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PrizeWinner>(
      where: where?.call(PrizeWinner.t),
      orderBy: orderBy?.call(PrizeWinner.t),
      orderByList: orderByList?.call(PrizeWinner.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PrizeWinner] by its [id] or null if no such row exists.
  Future<PrizeWinner?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PrizeWinner>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PrizeWinner]s in the list and returns the inserted rows.
  ///
  /// The returned [PrizeWinner]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PrizeWinner>> insert(
    _i1.DatabaseSession session,
    List<PrizeWinner> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PrizeWinner>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PrizeWinner] and returns the inserted row.
  ///
  /// The returned [PrizeWinner] will have its `id` field set.
  Future<PrizeWinner> insertRow(
    _i1.DatabaseSession session,
    PrizeWinner row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PrizeWinner>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PrizeWinner]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PrizeWinner>> update(
    _i1.DatabaseSession session,
    List<PrizeWinner> rows, {
    _i1.ColumnSelections<PrizeWinnerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PrizeWinner>(
      rows,
      columns: columns?.call(PrizeWinner.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PrizeWinner]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PrizeWinner> updateRow(
    _i1.DatabaseSession session,
    PrizeWinner row, {
    _i1.ColumnSelections<PrizeWinnerTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PrizeWinner>(
      row,
      columns: columns?.call(PrizeWinner.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PrizeWinner] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PrizeWinner?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<PrizeWinnerUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PrizeWinner>(
      id,
      columnValues: columnValues(PrizeWinner.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PrizeWinner]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PrizeWinner>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PrizeWinnerUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PrizeWinnerTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PrizeWinnerTable>? orderBy,
    _i1.OrderByListBuilder<PrizeWinnerTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PrizeWinner>(
      columnValues: columnValues(PrizeWinner.t.updateTable),
      where: where(PrizeWinner.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PrizeWinner.t),
      orderByList: orderByList?.call(PrizeWinner.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PrizeWinner]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PrizeWinner>> delete(
    _i1.DatabaseSession session,
    List<PrizeWinner> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PrizeWinner>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PrizeWinner].
  Future<PrizeWinner> deleteRow(
    _i1.DatabaseSession session,
    PrizeWinner row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PrizeWinner>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PrizeWinner>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PrizeWinnerTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PrizeWinner>(
      where: where(PrizeWinner.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PrizeWinnerTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PrizeWinner>(
      where: where?.call(PrizeWinner.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PrizeWinner] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PrizeWinnerTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PrizeWinner>(
      where: where(PrizeWinner.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
