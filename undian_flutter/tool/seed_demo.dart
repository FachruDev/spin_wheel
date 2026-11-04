// Mengisi server PENGEMBANGAN lokal dengan akun dan acara demo, supaya aplikasi bisa langsung
// dicoba tanpa mengambil kode verifikasi email secara manual. Jangan dipakai ke server produksi.
//
//   dart run tool/seed_demo.dart <file-log-server> [url-server]
//
// <file-log-server> adalah keluaran `dart bin/main.dart`; kode verifikasi pendaftaran dibaca dari sana.
// Aman dijalankan berulang: akun, organisasi, dan acara yang sudah ada dipakai ulang.
import 'dart:io';

import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart' show ClientAuthSessionManagerExtension;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';
import 'package:undian_client/undian_client.dart';

import 'sample_data.dart';

/// Akun khusus database lokal. Bukan akun sungguhan.
const demoEmail = 'demo@undian.test';
const demoPassword = 'Demo-Undian-2026';
const organizationName = 'PT Demo Sejahtera';
const eventName = 'Undian HUT 2026 (Demo)';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Pakai: dart run tool/seed_demo.dart <file-log-server> [url-server]');
    exit(64);
  }
  final serverLog = args[0];
  final session = ClientAuthSessionManager(storage: _MemoryStorage());
  final client = Client(args.length > 1 ? args[1] : 'http://localhost:8080/')..authSessionManager = session;

  await session.updateSignedInUser(await _signIn(client, serverLog));
  stdout.writeln('Masuk sebagai $demoEmail');

  final organizations = await client.organization.mine();
  final organization =
      organizations.where((o) => o.organization.name == organizationName).firstOrNull?.organization ??
      (await client.organization.create(organizationName)).organization;

  final events = await client.event.list(organization.id!);
  final event =
      events.where((e) => e.name == eventName).firstOrNull ??
      await client.event.create(organization.id!, eventName, DateTime.now().toUtc(), false);

  final result = await client.participant.importRows(event.id!, [
    for (final p in SampleData.participants())
      ParticipantInput(
        nik: p.nik,
        name: p.name,
        area: p.area,
        department: p.department,
        employmentStatus: p.employmentStatus,
        points: p.points,
        groups: p.groups.toList()..sort(),
      ),
  ], false);
  stdout.writeln('Peserta: ${result.inserted} baru, ${result.updated} diperbarui');

  if ((await client.prize.list(event.id!)).isEmpty) {
    var order = 0;
    for (final p in SampleData.prizes()) {
      await client.prize.save(
        EventPrize(
          eventId: event.id!,
          name: p.name,
          kind: PrizeKind.values.byName(p.kind.name),
          quantity: p.quantity,
          sortOrder: ++order,
          eligibleGroups: p.eligibleGroups.toList()..sort(),
          openToAll: p.openToAll,
        ),
      );
    }
  }
  stdout.writeln('Siap: organisasi "$organizationName", acara "$eventName".');
  exit(0);
}

/// Masuk; bila akun belum ada, daftar dulu dengan kode verifikasi dari log server.
Future<AuthSuccess> _signIn(Client client, String serverLog) async {
  try {
    return await client.emailIdp.login(email: demoEmail, password: demoPassword);
  } on EmailAccountLoginException {
    final requestId = await client.emailIdp.startRegistration(email: demoEmail);
    final code = await _registrationCode(serverLog);
    final token = await client.emailIdp.verifyRegistrationCode(accountRequestId: requestId, verificationCode: code);
    return client.emailIdp.finishRegistration(registrationToken: token, password: demoPassword);
  }
}

Future<String> _registrationCode(String serverLog) async {
  final pattern = RegExp('Registration code \\(${RegExp.escape(demoEmail)}\\): (\\S+)');
  for (var i = 0; i < 50; i++) {
    final match = pattern.allMatches(await File(serverLog).readAsString()).lastOrNull;
    if (match != null) return match.group(1)!;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  throw StateError('Kode verifikasi untuk $demoEmail tidak ditemukan di $serverLog');
}

class _MemoryStorage implements ClientAuthSuccessStorage {
  AuthSuccess? _data;

  @override
  Future<AuthSuccess?> get() async => _data;

  @override
  Future<void> set(AuthSuccess? data) async => _data = data;
}
