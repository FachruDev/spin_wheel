import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:undian_flutter/app/fonts.dart';
import 'package:undian_flutter/features/stage/stage_controller.dart';
import 'package:undian_flutter/features/stage/stage_page.dart';
import 'package:undian_flutter/features/stage/stage_routes.dart';

/// Membuka panggung demo dan mengembalikan container ProviderScope milik panggung.
Future<ProviderContainer> pumpDemoStage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    initialLocation: '/demo',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Text('Beranda')),
      GoRoute(path: '/demo', builder: (_, _) => const DemoStageRoute()),
    ],
  );
  await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
  await tester.pump();
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(StagePage)));
}

void main() {
  setUp(() => AppFonts.useGoogleFonts = false);

  testWidgets('panggung demo tampil dan Spasi memulai undian', (tester) async {
    final container = await pumpDemoStage(tester);
    expect(find.text('Panel Operator'), findsOneWidget);
    expect(find.text('HADIAH BERIKUTNYA'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(container.read(stageControllerProvider).phase, isA<StageShow>());

    // Biarkan animasi kartu selesai, lalu tombol berubah menjadi LANJUT.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 100));
    expect(container.read(stageControllerProvider).isAnimating, isFalse);
    expect(find.text('LANJUT  (Spasi)'), findsOneWidget);
  });

  testWidgets('identitas demo bisa diubah, dan spasi saat mengetik tidak memicu undian', (tester) async {
    final container = await pumpDemoStage(tester);
    await tester.tap(find.text('Tampilan'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).first, 'PT Maju Bersama');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.tap(find.text('Biru Korporat'));
    await tester.tap(find.text('Simpan'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(stageControllerProvider).phase, isA<StageIdle>());
    expect(find.text('PT MAJU BERSAMA'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  testWidgets('Spasi tetap berfungsi setelah operator mengklik hadiah di panel', (tester) async {
    final container = await pumpDemoStage(tester);
    await tester.tap(find.text('Sepeda Motor Matic'));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    final phase = container.read(stageControllerProvider).phase;
    expect(phase, isA<StageShow>());
    expect((phase as StageShow).mode, RevealMode.panggung);

    await tester.pump(const Duration(seconds: 14));
  });

  testWidgets('Esc keluar dari panggung', (tester) async {
    await pumpDemoStage(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Beranda'), findsOneWidget);
  });
}
