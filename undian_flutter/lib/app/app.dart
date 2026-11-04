import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/offline/backup/auto_backup.dart';
import 'fonts.dart';
import 'router.dart';

class UndianApp extends ConsumerWidget {
  const UndianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Salinan otomatis acara dari server berjalan selama aplikasi terbuka (desktop saja).
    ref.listen(autoBackupProvider, (_, _) {});
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5), brightness: Brightness.dark),
    );
    return MaterialApp.router(
      title: 'Undian',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(textTheme: AppFonts.textTheme(base.textTheme)),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
