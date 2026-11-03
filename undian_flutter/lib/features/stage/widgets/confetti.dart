import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'common.dart';

enum ConfettiStyle {
  /// Ditembakkan dari dua sudut bawah, untuk grand prize.
  cannons,

  /// Hujan dari atas, lebih tenang, untuk doorprize.
  rain,
}

/// Ledakan confetti sekali jalan di kanvas panggung. Berhenti sendiri setelah selesai.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key, required this.colors, this.style = ConfettiStyle.cannons, this.count = 220});

  final List<Color> colors;
  final ConfettiStyle style;
  final int count;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _Particle {
  _Particle({
    required this.position,
    required this.velocity,
    required this.spin,
    required this.size,
    required this.color,
    required this.wobble,
    required this.round,
  });

  Offset position;
  Offset velocity;
  double angle = 0;
  final double spin;
  final Size size;
  final Color color;
  final double wobble;
  final bool round;
}

class _ConfettiBurstState extends State<ConfettiBurst> with SingleTickerProviderStateMixin {
  static const _lifetime = 5.5;

  final _frame = ValueNotifier<double>(0);
  late final List<_Particle> _particles;
  late final Ticker _ticker;
  var _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _particles = List.generate(widget.count, (i) {
      final Offset position;
      final Offset velocity;
      if (widget.style == ConfettiStyle.cannons) {
        final left = i.isEven;
        final angle = (left ? -62 : -118) * math.pi / 180 + (rnd.nextDouble() - 0.5) * 0.5;
        final speed = 1200 + rnd.nextDouble() * 1100;
        position = Offset(left ? -20 : kStageSize.width + 20, kStageSize.height + 20);
        velocity = Offset(math.cos(angle), math.sin(angle)) * speed;
      } else {
        position = Offset(rnd.nextDouble() * kStageSize.width, -20 - rnd.nextDouble() * 500);
        velocity = Offset((rnd.nextDouble() - 0.5) * 160, 150 + rnd.nextDouble() * 250);
      }
      return _Particle(
        position: position,
        velocity: velocity,
        spin: (rnd.nextDouble() - 0.5) * 14,
        size: Size(10 + rnd.nextDouble() * 12, 6 + rnd.nextDouble() * 8),
        color: widget.colors[rnd.nextInt(widget.colors.length)],
        wobble: rnd.nextDouble() * math.pi * 2,
        round: rnd.nextDouble() < 0.25,
      );
    });
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final gravity = widget.style == ConfettiStyle.cannons ? 1100.0 : 260.0;
    final drag = math.pow(0.35, dt).toDouble();
    for (final p in _particles) {
      p.velocity = p.velocity * drag + Offset(0, gravity * dt);
      p.position += p.velocity * dt;
      p.angle += p.spin * dt;
    }
    final seconds = elapsed.inMicroseconds / 1e6;
    _frame.value = seconds;
    if (seconds > _lifetime) _ticker.stop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(painter: _ConfettiPainter(_particles, _frame), size: Size.infinite),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.frame) : super(repaint: frame);

  final List<_Particle> particles;
  final ValueNotifier<double> frame;

  @override
  void paint(Canvas canvas, Size size) {
    final t = frame.value;
    final fade = 1 - interval(t, 4.2, 5.5);
    if (fade <= 0) return;
    final paint = Paint();
    for (final p in particles) {
      paint.color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.angle);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size.height * 0.6, paint);
      } else {
        // Menyempit-melebar seperti kertas yang berputar di udara.
        final flutter = math.cos(t * 9 + p.wobble).abs() * 0.85 + 0.15;
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size.width, height: p.size.height * flutter),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
