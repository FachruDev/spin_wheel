import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:undian_client/undian_client.dart';

/// Alamat API server. Diisi saat build: `--dart-define=SERVER_URL=https://api.contoh.id/`.
const serverUrl = String.fromEnvironment('SERVER_URL', defaultValue: 'http://localhost:8080/');

/// Membuat client dan memulihkan sesi login yang tersimpan di perangkat.
Future<Client> createClient() async {
  final client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  await client.auth.initialize();
  return client;
}

/// Client Serverpod; di-override di `main()` dengan hasil [createClient].
final clientProvider = Provider<Client>((ref) => throw UnimplementedError('clientProvider belum di-override'));
