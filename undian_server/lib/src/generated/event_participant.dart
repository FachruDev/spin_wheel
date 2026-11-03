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

/// Peserta undian dalam satu acara.
abstract class EventParticipant
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = EventParticipantTable();

  static const db = EventParticipantRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static EventParticipantInclude include() {
    return EventParticipantInclude._();
  }

  static EventParticipantIncludeList includeList({
    _i1.WhereExpressionBuilder<EventParticipantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EventParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EventParticipantTable>? orderByList,
    EventParticipantInclude? include,
  }) {
    return EventParticipantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EventParticipant.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(EventParticipant.t),
      include: include,
    );
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

class EventParticipantUpdateTable
    extends _i1.UpdateTable<EventParticipantTable> {
  EventParticipantUpdateTable(super.table);

  _i1.ColumnValue<int, int> eventId(int value) => _i1.ColumnValue(
    table.eventId,
    value,
  );

  _i1.ColumnValue<String, String> nik(String value) => _i1.ColumnValue(
    table.nik,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> area(String value) => _i1.ColumnValue(
    table.area,
    value,
  );

  _i1.ColumnValue<String, String> department(String value) => _i1.ColumnValue(
    table.department,
    value,
  );

  _i1.ColumnValue<String, String> employmentStatus(String value) =>
      _i1.ColumnValue(
        table.employmentStatus,
        value,
      );

  _i1.ColumnValue<String, String> phone(String? value) => _i1.ColumnValue(
    table.phone,
    value,
  );

  _i1.ColumnValue<int, int> points(int value) => _i1.ColumnValue(
    table.points,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> groups(List<String> value) =>
      _i1.ColumnValue(
        table.groups,
        value,
      );
}

class EventParticipantTable extends _i1.Table<int?> {
  EventParticipantTable({super.tableRelation})
    : super(tableName: 'participant') {
    updateTable = EventParticipantUpdateTable(this);
    eventId = _i1.ColumnInt(
      'eventId',
      this,
    );
    nik = _i1.ColumnString(
      'nik',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    area = _i1.ColumnString(
      'area',
      this,
    );
    department = _i1.ColumnString(
      'department',
      this,
    );
    employmentStatus = _i1.ColumnString(
      'employmentStatus',
      this,
    );
    phone = _i1.ColumnString(
      'phone',
      this,
    );
    points = _i1.ColumnInt(
      'points',
      this,
    );
    groups = _i1.ColumnSerializable<List<String>>(
      'groups',
      this,
    );
  }

  late final EventParticipantUpdateTable updateTable;

  late final _i1.ColumnInt eventId;

  /// Nomor induk karyawan, sekaligus nomor undian. Unik per acara.
  late final _i1.ColumnString nik;

  late final _i1.ColumnString name;

  late final _i1.ColumnString area;

  late final _i1.ColumnString department;

  late final _i1.ColumnString employmentStatus;

  late final _i1.ColumnString phone;

  /// Bobot peluang: poin N = N tiket undian.
  late final _i1.ColumnInt points;

  /// Grup yang diikuti, mis. ["Doorprize Bogor", "Grandprize Bogor"].
  late final _i1.ColumnSerializable<List<String>> groups;

  @override
  List<_i1.Column> get columns => [
    id,
    eventId,
    nik,
    name,
    area,
    department,
    employmentStatus,
    phone,
    points,
    groups,
  ];
}

class EventParticipantInclude extends _i1.IncludeObject {
  EventParticipantInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => EventParticipant.t;
}

class EventParticipantIncludeList extends _i1.IncludeList {
  EventParticipantIncludeList._({
    _i1.WhereExpressionBuilder<EventParticipantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(EventParticipant.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => EventParticipant.t;
}

class EventParticipantRepository {
  const EventParticipantRepository._();

  /// Returns a list of [EventParticipant]s matching the given query parameters.
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
  Future<List<EventParticipant>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EventParticipantTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EventParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EventParticipantTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<EventParticipant>(
      where: where?.call(EventParticipant.t),
      orderBy: orderBy?.call(EventParticipant.t),
      orderByList: orderByList?.call(EventParticipant.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [EventParticipant] matching the given query parameters.
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
  Future<EventParticipant?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EventParticipantTable>? where,
    int? offset,
    _i1.OrderByBuilder<EventParticipantTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<EventParticipantTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<EventParticipant>(
      where: where?.call(EventParticipant.t),
      orderBy: orderBy?.call(EventParticipant.t),
      orderByList: orderByList?.call(EventParticipant.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [EventParticipant] by its [id] or null if no such row exists.
  Future<EventParticipant?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<EventParticipant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [EventParticipant]s in the list and returns the inserted rows.
  ///
  /// The returned [EventParticipant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<EventParticipant>> insert(
    _i1.DatabaseSession session,
    List<EventParticipant> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<EventParticipant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [EventParticipant] and returns the inserted row.
  ///
  /// The returned [EventParticipant] will have its `id` field set.
  Future<EventParticipant> insertRow(
    _i1.DatabaseSession session,
    EventParticipant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<EventParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [EventParticipant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<EventParticipant>> update(
    _i1.DatabaseSession session,
    List<EventParticipant> rows, {
    _i1.ColumnSelections<EventParticipantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<EventParticipant>(
      rows,
      columns: columns?.call(EventParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EventParticipant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<EventParticipant> updateRow(
    _i1.DatabaseSession session,
    EventParticipant row, {
    _i1.ColumnSelections<EventParticipantTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<EventParticipant>(
      row,
      columns: columns?.call(EventParticipant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [EventParticipant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<EventParticipant?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<EventParticipantUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<EventParticipant>(
      id,
      columnValues: columnValues(EventParticipant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [EventParticipant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<EventParticipant>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<EventParticipantUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<EventParticipantTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<EventParticipantTable>? orderBy,
    _i1.OrderByListBuilder<EventParticipantTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<EventParticipant>(
      columnValues: columnValues(EventParticipant.t.updateTable),
      where: where(EventParticipant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(EventParticipant.t),
      orderByList: orderByList?.call(EventParticipant.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [EventParticipant]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<EventParticipant>> delete(
    _i1.DatabaseSession session,
    List<EventParticipant> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<EventParticipant>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [EventParticipant].
  Future<EventParticipant> deleteRow(
    _i1.DatabaseSession session,
    EventParticipant row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<EventParticipant>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<EventParticipant>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EventParticipantTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<EventParticipant>(
      where: where(EventParticipant.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<EventParticipantTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<EventParticipant>(
      where: where?.call(EventParticipant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [EventParticipant] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<EventParticipantTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<EventParticipant>(
      where: where(EventParticipant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
