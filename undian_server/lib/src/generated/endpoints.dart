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
import '../auth/email_idp_endpoint.dart' as _i2;
import '../auth/jwt_refresh_endpoint.dart' as _i3;
import '../endpoints/draw_endpoint.dart' as _i4;
import '../endpoints/event_endpoint.dart' as _i5;
import '../endpoints/organization_endpoint.dart' as _i6;
import '../endpoints/participant_endpoint.dart' as _i7;
import '../endpoints/prize_endpoint.dart' as _i8;
import 'package:undian_server/src/generated/winner_status.dart' as _i9;
import 'dart:typed_data' as _i10;
import 'package:undian_server/src/generated/participant_input.dart' as _i11;
import 'package:undian_server/src/generated/event_prize.dart' as _i12;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i13;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i14;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'emailIdp': _i2.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _i3.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'draw': _i4.DrawEndpoint()
        ..initialize(
          server,
          'draw',
          null,
        ),
      'event': _i5.EventEndpoint()
        ..initialize(
          server,
          'event',
          null,
        ),
      'organization': _i6.OrganizationEndpoint()
        ..initialize(
          server,
          'organization',
          null,
        ),
      'participant': _i7.ParticipantEndpoint()
        ..initialize(
          server,
          'participant',
          null,
        ),
      'prize': _i8.PrizeEndpoint()
        ..initialize(
          server,
          'prize',
          null,
        ),
    };
    connectors['emailIdp'] = _i1.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint).login(
                session,
                email: params['email'],
                password: params['password'],
              ),
        ),
        'startRegistration': _i1.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _i1.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _i1.ParameterDescription(
              name: 'accountRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _i1.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _i1.ParameterDescription(
              name: 'registrationToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _i1.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _i1.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _i1.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _i1.getType<_i1.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _i1.ParameterDescription(
              name: 'verificationCode',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _i1.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _i1.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _i1.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _i2.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _i1.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _i1.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _i1.ParameterDescription(
              name: 'refreshToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['jwtRefresh'] as _i3.JwtRefreshEndpoint)
                  .refreshAccessToken(
                    session,
                    refreshToken: params['refreshToken'],
                  ),
        ),
      },
    );
    connectors['draw'] = _i1.EndpointConnector(
      name: 'draw',
      endpoint: endpoints['draw']!,
      methodConnectors: {
        'draw': _i1.MethodConnector(
          name: 'draw',
          params: {
            'prizeId': _i1.ParameterDescription(
              name: 'prizeId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'count': _i1.ParameterDescription(
              name: 'count',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['draw'] as _i4.DrawEndpoint).draw(
                session,
                params['prizeId'],
                params['count'],
              ),
        ),
        'setStatus': _i1.MethodConnector(
          name: 'setStatus',
          params: {
            'winnerId': _i1.ParameterDescription(
              name: 'winnerId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<_i9.WinnerStatus>(),
              nullable: false,
            ),
            'note': _i1.ParameterDescription(
              name: 'note',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['draw'] as _i4.DrawEndpoint).setStatus(
                session,
                params['winnerId'],
                params['status'],
                params['note'],
              ),
        ),
        'winners': _i1.MethodConnector(
          name: 'winners',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['draw'] as _i4.DrawEndpoint).winners(
                session,
                params['eventId'],
              ),
        ),
      },
    );
    connectors['event'] = _i1.EndpointConnector(
      name: 'event',
      endpoint: endpoints['event']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'eventDate': _i1.ParameterDescription(
              name: 'eventDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'allowMultipleWins': _i1.ParameterDescription(
              name: 'allowMultipleWins',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['event'] as _i5.EventEndpoint).create(
                session,
                params['organizationId'],
                params['name'],
                params['eventDate'],
                params['allowMultipleWins'],
              ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'eventDate': _i1.ParameterDescription(
              name: 'eventDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'allowMultipleWins': _i1.ParameterDescription(
              name: 'allowMultipleWins',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['event'] as _i5.EventEndpoint).update(
                session,
                params['eventId'],
                params['name'],
                params['eventDate'],
                params['allowMultipleWins'],
              ),
        ),
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['event'] as _i5.EventEndpoint).list(
                session,
                params['organizationId'],
              ),
        ),
      },
    );
    connectors['organization'] = _i1.EndpointConnector(
      name: 'organization',
      endpoint: endpoints['organization']!,
      methodConnectors: {
        'create': _i1.MethodConnector(
          name: 'create',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['organization'] as _i6.OrganizationEndpoint)
                  .create(
                    session,
                    params['name'],
                  ),
        ),
        'mine': _i1.MethodConnector(
          name: 'mine',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['organization'] as _i6.OrganizationEndpoint)
                  .mine(session),
        ),
        'updateBranding': _i1.MethodConnector(
          name: 'updateBranding',
          params: {
            'organizationId': _i1.ParameterDescription(
              name: 'organizationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'primaryColor': _i1.ParameterDescription(
              name: 'primaryColor',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'accentColor': _i1.ParameterDescription(
              name: 'accentColor',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'logo': _i1.ParameterDescription(
              name: 'logo',
              type: _i1.getType<_i10.ByteData?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['organization'] as _i6.OrganizationEndpoint)
                  .updateBranding(
                    session,
                    params['organizationId'],
                    params['name'],
                    params['primaryColor'],
                    params['accentColor'],
                    params['logo'],
                  ),
        ),
      },
    );
    connectors['participant'] = _i1.EndpointConnector(
      name: 'participant',
      endpoint: endpoints['participant']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['participant'] as _i7.ParticipantEndpoint).list(
                    session,
                    params['eventId'],
                  ),
        ),
        'importRows': _i1.MethodConnector(
          name: 'importRows',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'rows': _i1.ParameterDescription(
              name: 'rows',
              type: _i1.getType<List<_i11.ParticipantInput>>(),
              nullable: false,
            ),
            'replaceAll': _i1.ParameterDescription(
              name: 'replaceAll',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['participant'] as _i7.ParticipantEndpoint)
                  .importRows(
                    session,
                    params['eventId'],
                    params['rows'],
                    params['replaceAll'],
                  ),
        ),
        'add': _i1.MethodConnector(
          name: 'add',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'input': _i1.ParameterDescription(
              name: 'input',
              type: _i1.getType<_i11.ParticipantInput>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['participant'] as _i7.ParticipantEndpoint).add(
                    session,
                    params['eventId'],
                    params['input'],
                  ),
        ),
        'update': _i1.MethodConnector(
          name: 'update',
          params: {
            'participantId': _i1.ParameterDescription(
              name: 'participantId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'input': _i1.ParameterDescription(
              name: 'input',
              type: _i1.getType<_i11.ParticipantInput>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['participant'] as _i7.ParticipantEndpoint).update(
                    session,
                    params['participantId'],
                    params['input'],
                  ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'participantId': _i1.ParameterDescription(
              name: 'participantId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['participant'] as _i7.ParticipantEndpoint).delete(
                    session,
                    params['participantId'],
                  ),
        ),
      },
    );
    connectors['prize'] = _i1.EndpointConnector(
      name: 'prize',
      endpoint: endpoints['prize']!,
      methodConnectors: {
        'list': _i1.MethodConnector(
          name: 'list',
          params: {
            'eventId': _i1.ParameterDescription(
              name: 'eventId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['prize'] as _i8.PrizeEndpoint).list(
                session,
                params['eventId'],
              ),
        ),
        'save': _i1.MethodConnector(
          name: 'save',
          params: {
            'prize': _i1.ParameterDescription(
              name: 'prize',
              type: _i1.getType<_i12.EventPrize>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['prize'] as _i8.PrizeEndpoint).save(
                session,
                params['prize'],
              ),
        ),
        'delete': _i1.MethodConnector(
          name: 'delete',
          params: {
            'prizeId': _i1.ParameterDescription(
              name: 'prizeId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['prize'] as _i8.PrizeEndpoint).delete(
                session,
                params['prizeId'],
              ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _i13.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _i14.Endpoints()
      ..initializeEndpoints(server);
  }
}
