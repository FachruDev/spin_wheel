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
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'audit_log.dart' as _i5;
import 'draw_event.dart' as _i6;
import 'draw_result.dart' as _i7;
import 'event_participant.dart' as _i8;
import 'event_prize.dart' as _i9;
import 'import_result.dart' as _i10;
import 'member_role.dart' as _i11;
import 'membership.dart' as _i12;
import 'my_organization.dart' as _i13;
import 'organization.dart' as _i14;
import 'participant_input.dart' as _i15;
import 'prize_kind.dart' as _i16;
import 'prize_winner.dart' as _i17;
import 'undian_exception.dart' as _i18;
import 'winner_status.dart' as _i19;
import 'package:undian_server/src/generated/prize_winner.dart' as _i20;
import 'package:undian_server/src/generated/draw_event.dart' as _i21;
import 'package:undian_server/src/generated/my_organization.dart' as _i22;
import 'package:undian_server/src/generated/event_participant.dart' as _i23;
import 'package:undian_server/src/generated/participant_input.dart' as _i24;
import 'package:undian_server/src/generated/event_prize.dart' as _i25;
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

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'audit_log',
      dartName: 'AuditLog',
      schema: 'public',
      module: 'undian',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'audit_log_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'organizationId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'eventId',
          columnType: _i2.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'action',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'detail',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'audit_log_fk_0',
          columns: ['organizationId'],
          referenceTable: 'organization',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'audit_log_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'audit_log_org_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'draw_event',
      dartName: 'DrawEvent',
      schema: 'public',
      module: 'undian',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'draw_event_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'organizationId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'eventDate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _i2.ColumnDefinition(
          name: 'allowMultipleWins',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'draw_event_fk_0',
          columns: ['organizationId'],
          referenceTable: 'organization',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'draw_event_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'draw_event_org_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'membership',
      dartName: 'Membership',
      schema: 'public',
      module: 'undian',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'membership_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'organizationId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'role',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MemberRole',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'membership_fk_0',
          columns: ['organizationId'],
          referenceTable: 'organization',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'membership_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'membership_org_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'organizationId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'membership_user_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'organization',
      dartName: 'Organization',
      schema: 'public',
      module: 'undian',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'organization_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'primaryColor',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'accentColor',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'logo',
          columnType: _i2.ColumnType.bytea,
          isNullable: true,
          dartType: 'dart:typed_data:ByteData?',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'organization_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'participant',
      dartName: 'EventParticipant',
      schema: 'public',
      module: 'undian',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'participant_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'eventId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'nik',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'area',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'department',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'employmentStatus',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'phone',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _i2.ColumnDefinition(
          name: 'points',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'groups',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'List<String>',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'participant_fk_0',
          columns: ['eventId'],
          referenceTable: 'draw_event',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'participant_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'participant_event_nik_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'nik',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'prize',
      dartName: 'EventPrize',
      schema: 'public',
      module: 'undian',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'prize_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'eventId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'name',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'kind',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PrizeKind',
        ),
        _i2.ColumnDefinition(
          name: 'quantity',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'sortOrder',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'eligibleGroups',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'List<String>',
        ),
        _i2.ColumnDefinition(
          name: 'openToAll',
          columnType: _i2.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'prize_fk_0',
          columns: ['eventId'],
          referenceTable: 'draw_event',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'prize_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'prize_event_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'winner',
      dartName: 'PrizeWinner',
      schema: 'public',
      module: 'undian',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'winner_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'eventId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'prizeId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'participantId',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'roundNo',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'status',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:WinnerStatus',
        ),
        _i2.ColumnDefinition(
          name: 'drawnAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _i2.ColumnDefinition(
          name: 'drawnBy',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'note',
          columnType: _i2.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'winner_fk_0',
          columns: ['eventId'],
          referenceTable: 'draw_event',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'winner_fk_1',
          columns: ['prizeId'],
          referenceTable: 'prize',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'winner_fk_2',
          columns: ['participantId'],
          referenceTable: 'participant',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'winner_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'winner_event_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'winner_prize_participant_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'prizeId',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'participantId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
    ..._i2.Protocol.targetTableDefinitions,
  ];

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

    if (t == _i5.AuditLog) {
      return _i5.AuditLog.fromJson(data) as T;
    }
    if (t == _i6.DrawEvent) {
      return _i6.DrawEvent.fromJson(data) as T;
    }
    if (t == _i7.DrawResult) {
      return _i7.DrawResult.fromJson(data) as T;
    }
    if (t == _i8.EventParticipant) {
      return _i8.EventParticipant.fromJson(data) as T;
    }
    if (t == _i9.EventPrize) {
      return _i9.EventPrize.fromJson(data) as T;
    }
    if (t == _i10.ImportResult) {
      return _i10.ImportResult.fromJson(data) as T;
    }
    if (t == _i11.MemberRole) {
      return _i11.MemberRole.fromJson(data) as T;
    }
    if (t == _i12.Membership) {
      return _i12.Membership.fromJson(data) as T;
    }
    if (t == _i13.MyOrganization) {
      return _i13.MyOrganization.fromJson(data) as T;
    }
    if (t == _i14.Organization) {
      return _i14.Organization.fromJson(data) as T;
    }
    if (t == _i15.ParticipantInput) {
      return _i15.ParticipantInput.fromJson(data) as T;
    }
    if (t == _i16.PrizeKind) {
      return _i16.PrizeKind.fromJson(data) as T;
    }
    if (t == _i17.PrizeWinner) {
      return _i17.PrizeWinner.fromJson(data) as T;
    }
    if (t == _i18.UndianException) {
      return _i18.UndianException.fromJson(data) as T;
    }
    if (t == _i19.WinnerStatus) {
      return _i19.WinnerStatus.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.AuditLog?>()) {
      return (data != null ? _i5.AuditLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.DrawEvent?>()) {
      return (data != null ? _i6.DrawEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.DrawResult?>()) {
      return (data != null ? _i7.DrawResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.EventParticipant?>()) {
      return (data != null ? _i8.EventParticipant.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.EventPrize?>()) {
      return (data != null ? _i9.EventPrize.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.ImportResult?>()) {
      return (data != null ? _i10.ImportResult.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.MemberRole?>()) {
      return (data != null ? _i11.MemberRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Membership?>()) {
      return (data != null ? _i12.Membership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.MyOrganization?>()) {
      return (data != null ? _i13.MyOrganization.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.Organization?>()) {
      return (data != null ? _i14.Organization.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.ParticipantInput?>()) {
      return (data != null ? _i15.ParticipantInput.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.PrizeKind?>()) {
      return (data != null ? _i16.PrizeKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.PrizeWinner?>()) {
      return (data != null ? _i17.PrizeWinner.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.UndianException?>()) {
      return (data != null ? _i18.UndianException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.WinnerStatus?>()) {
      return (data != null ? _i19.WinnerStatus.fromJson(data) : null) as T;
    }
    if (t == List<_i8.EventParticipant>) {
      return (data as List)
              .map((e) => deserialize<_i8.EventParticipant>(e))
              .toList()
          as T;
    }
    if (t == List<_i17.PrizeWinner>) {
      return (data as List)
              .map((e) => deserialize<_i17.PrizeWinner>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i20.PrizeWinner>) {
      return (data as List)
              .map((e) => deserialize<_i20.PrizeWinner>(e))
              .toList()
          as T;
    }
    if (t == List<_i21.DrawEvent>) {
      return (data as List).map((e) => deserialize<_i21.DrawEvent>(e)).toList()
          as T;
    }
    if (t == List<_i22.MyOrganization>) {
      return (data as List)
              .map((e) => deserialize<_i22.MyOrganization>(e))
              .toList()
          as T;
    }
    if (t == List<_i23.EventParticipant>) {
      return (data as List)
              .map((e) => deserialize<_i23.EventParticipant>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.ParticipantInput>) {
      return (data as List)
              .map((e) => deserialize<_i24.ParticipantInput>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.EventPrize>) {
      return (data as List).map((e) => deserialize<_i25.EventPrize>(e)).toList()
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.AuditLog => 'AuditLog',
      _i6.DrawEvent => 'DrawEvent',
      _i7.DrawResult => 'DrawResult',
      _i8.EventParticipant => 'EventParticipant',
      _i9.EventPrize => 'EventPrize',
      _i10.ImportResult => 'ImportResult',
      _i11.MemberRole => 'MemberRole',
      _i12.Membership => 'Membership',
      _i13.MyOrganization => 'MyOrganization',
      _i14.Organization => 'Organization',
      _i15.ParticipantInput => 'ParticipantInput',
      _i16.PrizeKind => 'PrizeKind',
      _i17.PrizeWinner => 'PrizeWinner',
      _i18.UndianException => 'UndianException',
      _i19.WinnerStatus => 'WinnerStatus',
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
      case _i5.AuditLog():
        return 'AuditLog';
      case _i6.DrawEvent():
        return 'DrawEvent';
      case _i7.DrawResult():
        return 'DrawResult';
      case _i8.EventParticipant():
        return 'EventParticipant';
      case _i9.EventPrize():
        return 'EventPrize';
      case _i10.ImportResult():
        return 'ImportResult';
      case _i11.MemberRole():
        return 'MemberRole';
      case _i12.Membership():
        return 'Membership';
      case _i13.MyOrganization():
        return 'MyOrganization';
      case _i14.Organization():
        return 'Organization';
      case _i15.ParticipantInput():
        return 'ParticipantInput';
      case _i16.PrizeKind():
        return 'PrizeKind';
      case _i17.PrizeWinner():
        return 'PrizeWinner';
      case _i18.UndianException():
        return 'UndianException';
      case _i19.WinnerStatus():
        return 'WinnerStatus';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
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
      return deserialize<_i5.AuditLog>(data['data']);
    }
    if (dataClassName == 'DrawEvent') {
      return deserialize<_i6.DrawEvent>(data['data']);
    }
    if (dataClassName == 'DrawResult') {
      return deserialize<_i7.DrawResult>(data['data']);
    }
    if (dataClassName == 'EventParticipant') {
      return deserialize<_i8.EventParticipant>(data['data']);
    }
    if (dataClassName == 'EventPrize') {
      return deserialize<_i9.EventPrize>(data['data']);
    }
    if (dataClassName == 'ImportResult') {
      return deserialize<_i10.ImportResult>(data['data']);
    }
    if (dataClassName == 'MemberRole') {
      return deserialize<_i11.MemberRole>(data['data']);
    }
    if (dataClassName == 'Membership') {
      return deserialize<_i12.Membership>(data['data']);
    }
    if (dataClassName == 'MyOrganization') {
      return deserialize<_i13.MyOrganization>(data['data']);
    }
    if (dataClassName == 'Organization') {
      return deserialize<_i14.Organization>(data['data']);
    }
    if (dataClassName == 'ParticipantInput') {
      return deserialize<_i15.ParticipantInput>(data['data']);
    }
    if (dataClassName == 'PrizeKind') {
      return deserialize<_i16.PrizeKind>(data['data']);
    }
    if (dataClassName == 'PrizeWinner') {
      return deserialize<_i17.PrizeWinner>(data['data']);
    }
    if (dataClassName == 'UndianException') {
      return deserialize<_i18.UndianException>(data['data']);
    }
    if (dataClassName == 'WinnerStatus') {
      return deserialize<_i19.WinnerStatus>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i5.AuditLog:
        return _i5.AuditLog.t;
      case _i6.DrawEvent:
        return _i6.DrawEvent.t;
      case _i8.EventParticipant:
        return _i8.EventParticipant.t;
      case _i9.EventPrize:
        return _i9.EventPrize.t;
      case _i12.Membership:
        return _i12.Membership.t;
      case _i14.Organization:
        return _i14.Organization.t;
      case _i17.PrizeWinner:
        return _i17.PrizeWinner.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'undian';

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
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
