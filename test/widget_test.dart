import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spin_wheel/app/app.dart';
import 'package:spin_wheel/app/fonts.dart';
import 'package:spin_wheel/features/stage/stage_controller.dart';

void main() {
  setUp(() => AppFonts.useGoogleFonts = false);

  testWidgets('layar panggung tampil dan Spasi memulai undian', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: UndianApp()));
    await tester.pump();

    expect(find.text('Panel Operator'), findsOneWidget);
    expect(find.text('HADIAH BERIKUTNYA'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    final container = ProviderScope.containerOf(tester.element(find.byType(UndianApp)));
    expect(container.read(stageControllerProvider).phase, isA<StageShow>());

    // Biarkan animasi kartu selesai, lalu pemenang muncul di panel.
    await tester.pump(const Duration(seconds: 6));
    await tester.pump(const Duration(milliseconds: 100));
    expect(container.read(stageControllerProvider).isAnimating, isFalse);
    expect(find.text('LANJUT  (Spasi)'), findsOneWidget);
  });

  testWidgets('identitas organisasi bisa diubah, dan spasi saat mengetik tidak memicu undian', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: UndianApp()));
    await tester.pump();
    await tester.tap(find.text('Tampilan'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).first, 'PT Maju Bersama');
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.tap(find.text('Biru Korporat'));
    await tester.tap(find.text('Simpan'));
    await tester.pump(const Duration(milliseconds: 300));

    final container = ProviderScope.containerOf(tester.element(find.byType(UndianApp)));
    expect(container.read(stageControllerProvider).phase, isA<StageIdle>());
    expect(find.text('PT MAJU BERSAMA'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
  });

  testWidgets('Spasi tetap berfungsi setelah operator mengklik hadiah di panel', (tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: UndianApp()));
    await tester.pump();
    await tester.tap(find.text('Sepeda Motor Matic'));
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    final container = ProviderScope.containerOf(tester.element(find.byType(UndianApp)));
    final phase = container.read(stageControllerProvider).phase;
    expect(phase, isA<StageShow>());
    expect((phase as StageShow).mode, RevealMode.panggung);

    await tester.pump(const Duration(seconds: 14));
  });
}
