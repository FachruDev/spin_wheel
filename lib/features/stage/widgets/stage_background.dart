import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Latar panggung: gradasi warna tema yang bergerak pelan dan partikel cahaya.
/// [energy] 0..1 mempercepat dan menerangkan latar saat undian berjalan.
class StageBackground extends StatefulWidget {
  const StageBackground({super.key, required this.primary, required this.accent, this.energy = 0});

  final Color primary;
  final Color accent;
  final double energy;

  @override
  State<StageBackground> createState() => _StageBackgroundState();
}

class _BackgroundClock extends ChangeNotifier {
  double time = 0;
  double energy = 0;

  void tick(double dt, double targetEnergy) {
    energy += (targetEnergy - energy) * math.min(1, dt * 1.5);
    time += dt * (1 + energy * 3);
    notifyListeners();
  }
}

class _StageBackgroundState extends State<StageBackground> with SingleTickerProviderStateMixin {
  final _clock = _BackgroundClock();
  late final Ticker _ticker;
  var _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      final dt = (elapsed - _last).inMicroseconds / 1e6;
      _last = elapsed;
      _clock.tick(dt, widget.energy);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _BackgroundPainter(_clock, widget.primary, widget.accent), size: Size.infinite),
  );
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter(this.clock, this.primary, this.accent) : super(repaint: clock);

  final _BackgroundClock clock;
  final Color primary;
  final Color accent;

  /// (x, y, radius, kecepatan naik) untuk tiap partikel.
  static final _stars = List.generate(90, (i) {
    final r = math.Random(i * 31 + 7);
    return (r.nextDouble(), r.nextDouble(), 0.6 + r.nextDouble() * 1.8, 6 + r.nextDouble() * 24);
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final t = clock.time;
    final e = clock.energy;
    const base = Color(0xFF05060F);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(base, primary, 0.22)!, const Color(0xFF040409), Color.lerp(base, accent, 0.08)!],
        ).createShader(rect),
    );

    for (final (color, phase) in [(primary, 0.0), (accent, 2.1), (Color.lerp(primary, accent, 0.5)!, 4.2)]) {
      final center = Offset(
        size.width * (0.5 + 0.38 * math.sin(t * 0.07 + phase)),
        size.height * (0.5 + 0.34 * math.cos(t * 0.05 + phase * 1.3)),
      );
      final radius = size.shortestSide * (0.55 + 0.1 * math.sin(t * 0.2 + phase));
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.2 + 0.12 * e),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    final star = Paint();
    for (var i = 0; i < _stars.length; i++) {
      final (x, y, r, speed) = _stars[i];
      final py = (y * size.height - t * speed) % size.height;
      final px = x * size.width + math.sin(t * 0.4 + i) * 12;
      final twinkle = 0.25 + 0.55 * (0.5 + 0.5 * math.sin(t * 1.7 + i * 1.3));
      star.color = Colors.white.withValues(alpha: twinkle * (0.6 + 0.4 * e));
      canvas.drawCircle(Offset(px, py), r * (1 + e * 0.5), star);
    }

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          radius: 0.95,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
          stops: const [0.55, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter old) => old.primary != primary || old.accent != accent;
}
