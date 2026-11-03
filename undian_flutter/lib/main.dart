import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/server/server_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final client = await createClient();
  runApp(ProviderScope(overrides: [clientProvider.overrideWithValue(client)], child: const UndianApp()));
}
