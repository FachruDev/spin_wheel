import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/branding/branding.dart';
import '../features/stage/stage_page.dart';
import 'fonts.dart';

final appRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (_, _) => const StagePage())],
);

class UndianApp extends ConsumerWidget {
  const UndianApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branding = ref.watch(brandingProvider);
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: branding.primary, brightness: Brightness.dark),
    );
    return MaterialApp.router(
      title: 'Undian · ${branding.organizationName}',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(textTheme: AppFonts.textTheme(base.textTheme)),
      routerConfig: appRouter,
    );
  }
}
