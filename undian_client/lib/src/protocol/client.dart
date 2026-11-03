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

import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i1;
import 'package:serverpod_client/serverpod_client.dart' as _i2;
import 'dart:async' as _i3;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i4;
import 'package:undian_client/src/protocol/draw_result.dart' as _i5;
import 'package:undian_client/src/protocol/prize_winner.dart' as _i6;
import 'package:undian_client/src/protocol/winner_status.dart' as _i7;
import 'package:undian_client/src/protocol/draw_event.dart' as _i8;
import 'package:undian_client/src/protocol/my_organization.dart' as _i9;
import 'package:undian_client/src/protocol/organization.dart' as _i10;
import 'dart:typed_data' as _i11;
import 'package:undian_client/src/protocol/event_participant.dart' as _i12;
import 'package:undian_client/src/protocol/import_result.dart' as _i13;
import 'package:undian_client/src/protocol/participant_input.dart' as _i14;
import 'package:undian_client/src/protocol/event_prize.dart' as _i15;
import 'protocol.dart' as _i16;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _i1.EndpointEmailIdpBase {
  EndpointEmailIdp(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<_i4.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _i3.Future<_i2.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _i3.Future<String> verifyRegistrationCode({
    required _i2.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _i3.Future<_i4.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _i3.Future<_i2.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_i2.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _i3.Future<String> verifyPasswordResetCode({
    required _i2.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _i3.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _i3.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _i4.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _i3.Future<_i4.AuthSuccess> refreshAccessToken({
    required String refreshToken,
  }) => caller.callServerEndpoint<_i4.AuthSuccess>(
    'jwtRefresh',
    'refreshAccessToken',
    {'refreshToken': refreshToken},
    authenticated: false,
  );
}

/// Pengundian. Hasil selalu ditentukan di server dan dicatat sebelum dikirim ke layar.
/// {@category Endpoint}
class EndpointDraw extends _i2.EndpointRef {
  EndpointDraw(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'draw';

  /// Mengundi [count] pemenang untuk [prizeId].
  ///
  /// Baris acara dikunci selama transaksi, jadi undian dalam satu acara berjalan bergantian
  /// dan satu orang tidak bisa memenangkan dua hadiah yang diundi bersamaan.
  _i3.Future<_i5.DrawResult> draw(
    int prizeId,
    int count,
  ) => caller.callServerEndpoint<_i5.DrawResult>(
    'draw',
    'draw',
    {
      'prizeId': prizeId,
      'count': count,
    },
  );

  /// Mengubah status pemenang. Hangus wajib beralasan dan bersifat final, karena unitnya
  /// kembali ke stok dan bisa langsung diundi ulang.
  _i3.Future<_i6.PrizeWinner> setStatus(
    int winnerId,
    _i7.WinnerStatus status,
    String? note,
  ) => caller.callServerEndpoint<_i6.PrizeWinner>(
    'draw',
    'setStatus',
    {
      'winnerId': winnerId,
      'status': status,
      'note': note,
    },
  );

  _i3.Future<List<_i6.PrizeWinner>> winners(int eventId) =>
      caller.callServerEndpoint<List<_i6.PrizeWinner>>(
        'draw',
        'winners',
        {'eventId': eventId},
      );
}

/// Acara undian dalam sebuah organisasi.
/// {@category Endpoint}
class EndpointEvent extends _i2.EndpointRef {
  EndpointEvent(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'event';

  _i3.Future<_i8.DrawEvent> create(
    int organizationId,
    String name,
    DateTime? eventDate,
    bool allowMultipleWins,
  ) => caller.callServerEndpoint<_i8.DrawEvent>(
    'event',
    'create',
    {
      'organizationId': organizationId,
      'name': name,
      'eventDate': eventDate,
      'allowMultipleWins': allowMultipleWins,
    },
  );

  _i3.Future<List<_i8.DrawEvent>> list(int organizationId) =>
      caller.callServerEndpoint<List<_i8.DrawEvent>>(
        'event',
        'list',
        {'organizationId': organizationId},
      );
}

/// Organisasi (tenant) milik pengguna: membuat, melihat, dan mengatur identitasnya.
/// {@category Endpoint}
class EndpointOrganization extends _i2.EndpointRef {
  EndpointOrganization(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'organization';

  /// Membuat organisasi baru; pembuatnya otomatis menjadi admin.
  _i3.Future<_i9.MyOrganization> create(String name) =>
      caller.callServerEndpoint<_i9.MyOrganization>(
        'organization',
        'create',
        {'name': name},
      );

  /// Semua organisasi tempat pengguna menjadi anggota.
  _i3.Future<List<_i9.MyOrganization>> mine() =>
      caller.callServerEndpoint<List<_i9.MyOrganization>>(
        'organization',
        'mine',
        {},
      );

  /// Mengubah nama, warna, dan logo organisasi. Hanya admin.
  _i3.Future<_i10.Organization> updateBranding(
    int organizationId,
    String name,
    int primaryColor,
    int accentColor,
    _i11.ByteData? logo,
  ) => caller.callServerEndpoint<_i10.Organization>(
    'organization',
    'updateBranding',
    {
      'organizationId': organizationId,
      'name': name,
      'primaryColor': primaryColor,
      'accentColor': accentColor,
      'logo': logo,
    },
  );
}

/// Peserta acara. File Excel dibaca di aplikasi; server menerima baris yang sudah dipetakan.
/// {@category Endpoint}
class EndpointParticipant extends _i2.EndpointRef {
  EndpointParticipant(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'participant';

  _i3.Future<List<_i12.EventParticipant>> list(int eventId) =>
      caller.callServerEndpoint<List<_i12.EventParticipant>>(
        'participant',
        'list',
        {'eventId': eventId},
      );

  /// Menyimpan baris peserta: NIK yang sudah ada diperbarui, yang baru ditambahkan.
  ///
  /// Dengan [replaceAll], peserta yang tidak ada di file dihapus. Ini ditolak jika acara
  /// sudah punya pemenang, supaya riwayat undian tidak hilang.
  _i3.Future<_i13.ImportResult> importRows(
    int eventId,
    List<_i14.ParticipantInput> rows,
    bool replaceAll,
  ) => caller.callServerEndpoint<_i13.ImportResult>(
    'participant',
    'importRows',
    {
      'eventId': eventId,
      'rows': rows,
      'replaceAll': replaceAll,
    },
  );
}

/// Hadiah dalam sebuah acara.
/// {@category Endpoint}
class EndpointPrize extends _i2.EndpointRef {
  EndpointPrize(_i2.EndpointCaller caller) : super(caller);

  @override
  String get name => 'prize';

  _i3.Future<List<_i15.EventPrize>> list(int eventId) =>
      caller.callServerEndpoint<List<_i15.EventPrize>>(
        'prize',
        'list',
        {'eventId': eventId},
      );

  /// Menambah hadiah baru (id kosong) atau memperbarui yang sudah ada.
  _i3.Future<_i15.EventPrize> save(_i15.EventPrize prize) =>
      caller.callServerEndpoint<_i15.EventPrize>(
        'prize',
        'save',
        {'prize': prize},
      );

  /// Menghapus hadiah yang belum pernah diundi.
  _i3.Future<void> delete(int prizeId) => caller.callServerEndpoint<void>(
    'prize',
    'delete',
    {'prizeId': prizeId},
  );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _i1.Caller(client);
    serverpod_auth_core = _i4.Caller(client);
  }

  late final _i1.Caller serverpod_auth_idp;

  late final _i4.Caller serverpod_auth_core;
}

class Client extends _i2.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i2.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i2.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i16.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    draw = EndpointDraw(this);
    event = EndpointEvent(this);
    organization = EndpointOrganization(this);
    participant = EndpointParticipant(this);
    prize = EndpointPrize(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointDraw draw;

  late final EndpointEvent event;

  late final EndpointOrganization organization;

  late final EndpointParticipant participant;

  late final EndpointPrize prize;

  late final Modules modules;

  @override
  Map<String, _i2.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'draw': draw,
    'event': event,
    'organization': organization,
    'participant': participant,
    'prize': prize,
  };

  @override
  Map<String, _i2.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
