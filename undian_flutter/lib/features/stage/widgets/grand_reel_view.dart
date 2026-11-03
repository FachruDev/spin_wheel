import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:undian_core/undian_core.dart';

import 'common.dart';
import 'confetti.dart';

/// Animasi grand prize "Panggung Utama":
/// intro sorot lampu → drum nama 3D berputar dan melambat (sempat nyaris lewat) →
/// kilat cahaya → kartu pemenang dan confetti.
class GrandReelView extends StatefulWidget {
  const GrandReelView({
    super.key,
    required this.prize,
    required this.winner,
    required this.pool,
    required this.primary,
    required this.accent,
    required this.onFinished,
  });

  final Prize prize;
  final Participant winner;
  final List<Participant> pool;
  final Color primary;
  final Color accent;
  final VoidCallback onFinished;

  @override
  State<GrandReelView> createState() => _GrandReelViewState();
}

class _GrandReelViewState extends State<GrandReelView> with SingleTickerProviderStateMixin {
  // Lini waktu dalam milidetik.
  static const _introEnd = 2600.0;
  static const _spinEnd = 10600.0;
  static const _revealAt = 10900.0;
  static const _total = 12800.0;

  /// Posisi nama pemenang di pita drum.
  static const _target = 62;
  static const _reelHeight = 720.0;
  static const _itemHeight = 128.0;

  late final List<Participant> _strip;
  late final AnimationController _controller;
  var _confetti = false;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    final others = widget.pool.where((p) => p.id != widget.winner.id).toList();
    _strip = [
      for (var i = 0; i < _target + 8; i++)
        i == _target || others.isEmpty ? widget.winner : others[rnd.nextInt(others.length)],
    ];
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 12800))
      ..addListener(() {
        if (!_confetti && _controller.value * _total >= _revealAt) setState(() => _confetti = true);
      });
    _controller.forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Posisi drum (satuan nama). Melambat seperti easeOutQuart, lalu di akhir sempat
  /// bergeser hampir setengah nama ke depan sebelum kembali ke pemenang.
  double _position(double e) {
    final u = interval(e, _introEnd - 200, _spinEnd);
    final base = _target * (1 - math.pow(1 - u, 4).toDouble());
    final nearMiss = 0.45 * math.sin(math.pi * interval(u, 0.82, 1));
    return base + nearMiss;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final e = _controller.value * _total;
        final introOpacity = 1 - interval(e, 2200, 2800);
        final reelOpacity = interval(e, 2300, 2900) * (1 - 0.85 * interval(e, _revealAt, _revealAt + 500));
        final flash = e < _spinEnd ? 0.0 : 1 - Curves.easeOut.transform(interval(e, _spinEnd, _spinEnd + 700));
        return Stack(
          fit: StackFit.expand,
          children: [
            if (introOpacity > 0) Opacity(key: const ValueKey('intro'), opacity: introOpacity, child: _intro(e)),
            if (reelOpacity > 0) Opacity(key: const ValueKey('reel'), opacity: reelOpacity, child: _reelStage(e)),
            if (e >= _revealAt) Center(key: const ValueKey('reveal'), child: _reveal(e)),
            if (flash > 0)
              IgnorePointer(
                key: const ValueKey('flash'),
                child: ColoredBox(color: Colors.white.withValues(alpha: 0.85 * flash)),
              ),
            if (_confetti)
              ConfettiBurst(
                key: const ValueKey('confetti'),
                colors: [widget.accent, widget.primary, Colors.white, const Color(0xFFFF6B9A), const Color(0xFF5EEAD4)],
              ),
          ],
        );
      },
    );
  }

  Widget _intro(double e) {
    final label = Curves.easeOut.transform(interval(e, 0, 700));
    final badge = Curves.easeOutBack.transform(interval(e, 300, 1300));
    final name = Curves.easeOutCubic.transform(interval(e, 700, 1600));
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _SpotlightPainter(seconds: e / 1000, color: widget.accent),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: label,
                child: Text(
                  'GRAND PRIZE',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 60 - 42 * label,
                    color: widget.accent,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Opacity(
                opacity: interval(e, 300, 700),
                child: Transform.scale(
                  scale: 0.4 + 0.6 * badge,
                  child: PrizeBadge(prize: widget.prize, primary: widget.primary, accent: widget.accent),
                ),
              ),
              const SizedBox(height: 40),
              Opacity(
                opacity: name,
                child: Transform.translate(
                  offset: Offset(0, 40 * (1 - name)),
                  child: Text(
                    widget.prize.name,
                    style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reelStage(double e) {
    final settled = e >= _spinEnd - 400;
    final pulse = settled ? 0.5 + 0.5 * math.sin(e / 90) : 0.0;
    return Column(
      children: [
        const SizedBox(height: 175),
        Text(
          'GRAND PRIZE',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 16, color: widget.accent),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(prizeIcon(widget.prize), size: 52, color: widget.accent),
            const SizedBox(width: 18),
            Text(
              widget.prize.name,
              style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ],
        ),
        Expanded(
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 1500,
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.accent.withValues(alpha: 0),
                        widget.accent.withValues(alpha: 0.14 + 0.2 * pulse),
                        widget.accent.withValues(alpha: 0),
                      ],
                    ),
                    border: Border.symmetric(
                      horizontal: BorderSide(color: widget.accent.withValues(alpha: 0.75), width: 3),
                    ),
                  ),
                ),
                _reel(e),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 90, color: widget.accent),
                    const SizedBox(width: 1320),
                    Transform.flip(flipX: true, child: Icon(Icons.play_arrow_rounded, size: 90, color: widget.accent)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _reel(double e) {
    final position = _position(e);
    final velocity = (_position(e + 16) - position) / 0.016; // nama per detik
    final blur = (velocity.abs() * 0.22).clamp(0.0, 9.0);
    final items = <Widget>[];
    for (var k = position.floor() - 5; k <= position.floor() + 6; k++) {
      if (k < 0 || k >= _strip.length) continue;
      final d = k - position;
      final angle = d * 0.34;
      if (angle.abs() > 1.4) continue;
      final focus = (1 - d.abs()).clamp(0.0, 1.0);
      items.add(
        Positioned(
          left: 0,
          right: 0,
          top: _reelHeight / 2 + math.sin(angle) * 360 - _itemHeight / 2,
          height: _itemHeight,
          child: Opacity(
            opacity: math.cos(angle).clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0009)
                ..rotateX(-angle),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _strip[k].name,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 72 + 18 * focus,
                        fontWeight: FontWeight.w800,
                        color: Color.lerp(Colors.white54, Colors.white, focus),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    Widget reel = SizedBox(
      width: 1300,
      height: _reelHeight,
      child: Stack(children: items),
    );
    if (blur > 0.4) {
      reel = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: blur),
        child: reel,
      );
    }
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
        stops: [0, 0.3, 0.7, 1],
      ).createShader(rect),
      child: reel,
    );
  }

  Widget _reveal(double e) {
    final t = interval(e, _revealAt, _revealAt + 900);
    return Opacity(
      opacity: interval(e, _revealAt, _revealAt + 300),
      child: Transform.scale(
        scale: 0.6 + 0.4 * Curves.easeOutBack.transform(t),
        child: WinnerSpotlightCard(
          person: widget.winner,
          prize: widget.prize,
          primary: widget.primary,
          accent: widget.accent,
        ),
      ),
    );
  }
}

/// Dua sorot lampu dari atas yang bergoyang pelan ke tengah panggung.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({required this.seconds, required this.color});

  final double seconds;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    for (final side in [-1.0, 1.0]) {
      final origin = Offset(center + side * size.width * 0.32, -40);
      final target = Offset(center + side * 40 + math.sin(seconds * 1.6 + side) * 140, size.height * 0.62);
      final path = Path()
        ..moveTo(origin.dx - 30, origin.dy)
        ..lineTo(origin.dx + 30, origin.dy)
        ..lineTo(target.dx + 300, target.dy + 200)
        ..lineTo(target.dx - 300, target.dy + 200)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = ui.Gradient.linear(origin, target, [
            Colors.white.withValues(alpha: 0.2),
            color.withValues(alpha: 0.02),
          ]),
      );
    }
    final floor = Rect.fromCenter(center: Offset(center, size.height * 0.84), width: 1400, height: 260);
    canvas.drawOval(
      floor,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
        ).createShader(floor),
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.seconds != seconds || old.color != color;
}
