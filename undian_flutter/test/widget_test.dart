import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:undian_flutter/app/fonts.dart';
import 'package:undian_flutter/features/branding/branding.dart';
import 'package:undian_flutter/features/participants/import/import_dialog.dart';
import 'package:undian_flutter/features/stage/operator_panel.dart';
import 'package:undian_flutter/features/stage/stage_controller.dart';
import 'package:undian_flutter/features/stage/stage_page.dart';

import 'support/local_stage_gateway.dart';

/// Membuka panggung berisi data contoh dan mengembalikan container ProviderScope milik panggung.
Future<ProviderContainer> pumpStage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1920, 1080);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final gateway = LocalStageGateway();
  final router = GoRouter(
    initialLocation: '/panggung',
    routes: [
      GoRoute(path: '/', builder: (_, _) => const Text('Beranda')),
      GoRoute(
        path: '/panggung',
        builder: (_, _) => ProviderScope(
          overrides: [
            stageGatewayProvider.overrideWithValue(gateway),
            stageBrandingProvider.overrideWithValue(const Branding(organizationName: 'PT Maju Bersama')),
          ],
          child: const StagePage(),
        ),
      ),
    ],
  );
  await tester.pumpWidget(ProviderScope(child: MaterialApp.router(routerConfig: router)));
  await tester.pump();
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(StagePage)));
}

void main() {
  setUp(() => AppFonts.useGoogleFonts = false);

  testWidgets('panggung tampil dan Spasi memulai undian', (tester) async {
    final container = await pumpStage(tester);
    expect(find.text('Panel Operator'), findsOneWidget);
    expect(find.text('PT MAJU BERSAMA'), findsOneWidget);
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

  testWidgets('Spasi saat mengetik di dialog tidak memicu undian', (tester) async {
    final container = await pumpStage(tester);
    showDialog<void>(
      context: tester.element(find.byType(StagePage)),
      builder: (_) => const AlertDialog(content: TextField(autofocus: true)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(find.byType(TextField), 'Tidak hadir');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(container.read(stageControllerProvider).phase, isA<StageIdle>());
  });

  testWidgets('Spasi tetap berfungsi setelah operator mengklik hadiah di panel', (tester) async {
    final container = await pumpStage(tester);
    final motor = find.text('Sepeda Motor Matic');
    await tester.scrollUntilVisible(
      motor,
      200,
      scrollable: find.descendant(of: find.byType(OperatorPanel), matching: find.byType(Scrollable)).first,
    );
    await tester.tap(motor);
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    final phase = container.read(stageControllerProvider).phase;
    expect(phase, isA<StageShow>());
    expect((phase as StageShow).mode, RevealMode.panggung);

    await tester.pump(const Duration(seconds: 14));
  });

  testWidgets('dialog import menawarkan pilih file dan unduh template', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: ImportDialog(eventId: 1, hasWinners: false))),
      ),
    );
    expect(find.text('Pilih file Excel'), findsOneWidget);
    expect(find.text('Unduh template Excel'), findsOneWidget);
  });

  testWidgets('Esc keluar dari panggung', (tester) async {
    await pumpStage(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Beranda'), findsOneWidget);
  });
}
