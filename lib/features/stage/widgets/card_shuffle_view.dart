import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:undian_core/undian_core.dart';

import '../../../app/fonts.dart';
import 'common.dart';
import 'confetti.dart';

/// Animasi doorprize "Kartu Kocok": semua kartu mengocok nama peserta berhak,
/// lalu berhenti bergelombang dan berbalik 3D menampilkan pemenang.
class CardShuffleView extends StatefulWidget {
  const CardShuffleView({
    super.key,
    required this.prize,
    required this.winners,
    required this.pool,
    required this.primary,
    required this.accent,
    required this.onFinished,
  });

  final Prize prize;
  final List<Participant> winners;
  final List<Participant> pool;
  final Color primary;
  final Color accent;
  final VoidCallback onFinished;

  @override
  State<CardShuffleView> createState() => _CardShuffleViewState();
}

class _CardShuffleViewState extends State<CardShuffleView> with SingleTickerProviderStateMixin {
  static const _shuffleMs = 1700.0;
  static const _flipMs = 650.0;
  static const _tailMs = 500.0;

  late final int _count = widget.winners.length;
  late final double _staggerMs = _count <= 5
      ? 450
      : _count <= 10
      ? 280
      : 190;
  late final double _totalMs = _shuffleMs + _staggerMs * (_count - 1) + _flipMs + _tailMs;

  /// Urutan nama acak yang ditampilkan tiap kartu selama dikocok.
  late final List<List<int>> _faces;
  late final AnimationController _controller;
  var _done = false;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random();
    _faces = List.generate(_count, (_) => List.generate(48, (_) => rnd.nextInt(widget.pool.length)));
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs.round()),
    );
    _controller.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _done = true);
      widget.onFinished();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(90, 180, 90, 100),
          child: Column(
            children: [
              _title(),
              const SizedBox(height: 36),
              Expanded(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) =>
                      LayoutBuilder(builder: (context, box) => _grid(box, _controller.value * _totalMs)),
                ),
              ),
            ],
          ),
        ),
        if (_done)
          ConfettiBurst(
            key: const ValueKey('confetti'),
            style: ConfettiStyle.rain,
            count: 160,
            colors: [widget.accent, widget.primary, Colors.white, const Color(0xFFFF6B9A), const Color(0xFF5EEAD4)],
          ),
      ],
    );
  }

  Widget _title() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(prizeIcon(widget.prize), size: 64, color: widget.accent),
      const SizedBox(width: 24),
      Flexible(
        child: Text(
          widget.prize.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
      const SizedBox(width: 28),
      StagePill('$_count PEMENANG', color: widget.accent),
    ],
  );

  Widget _grid(BoxConstraints box, double elapsed) {
    final cols = _count <= 4
        ? _count
        : _count <= 6
        ? 3
        : _count <= 8
        ? 4
        : 5;
    final rows = (_count / cols).ceil();
    const gap = 26.0;
    final cellH = math.min((box.maxHeight - gap * (rows - 1)) / rows, 330.0);
    final cellW = math.min((box.maxWidth - gap * (cols - 1)) / cols, cellH * 2.2);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var r = 0; r < rows; r++) ...[
          if (r > 0) const SizedBox(height: gap),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var c = 0; c < cols && r * cols + c < _count; c++) ...[
                if (c > 0) const SizedBox(width: gap),
                SizedBox(width: cellW, height: cellH, child: _card(r * cols + c, elapsed, cellH)),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _card(int i, double elapsed, double h) {
    final flip = ((elapsed - (_shuffleMs + i * _staggerMs)) / _flipMs).clamp(0.0, 1.0);
    final angle = Curves.easeInOutCubic.transform(flip) * math.pi;
    final face = angle > math.pi / 2
        ? Transform(alignment: Alignment.center, transform: Matrix4.rotationY(math.pi), child: _back(i, h, flip))
        : _front(i, elapsed, h);
    return Transform.scale(
      scale: 1 + 0.08 * math.sin(math.pi * flip),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateY(angle),
        child: face,
      ),
    );
  }

  Widget _front(int i, double elapsed, double h) {
    final tick = (elapsed / 70).floor();
    final faces = _faces[i];
    final person = widget.pool[faces[(tick + i * 5) % faces.length]];
    final glow = 0.5 + 0.5 * math.sin(elapsed / 120 + i);
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: h * 0.12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h * 0.14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.03)],
        ),
        border: Border.all(color: widget.accent.withValues(alpha: 0.15 + 0.25 * glow), width: 2),
      ),
      child: Text(
        person.name,
        maxLines: 2,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: h * 0.14,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.45),
          height: 1.15,
        ),
      ),
    );
  }

  Widget _back(int i, double h, double flip) {
    final person = widget.winners[i];
    return Container(
      padding: EdgeInsets.all(h * 0.09),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h * 0.14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(widget.primary, Colors.black, 0.25)!, Color.lerp(widget.primary, Colors.black, 0.7)!],
        ),
        border: Border.all(color: widget.accent, width: 2.5),
        boxShadow: [BoxShadow(color: widget.accent.withValues(alpha: 0.45 * flip), blurRadius: 40, spreadRadius: 2)],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              '#${i + 1}',
              style: TextStyle(fontSize: h * 0.09, fontWeight: FontWeight.w800, color: widget.accent),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  person.name,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: h * 0.14, fontWeight: FontWeight.w800, color: Colors.white, height: 1.15),
                ),
                SizedBox(height: h * 0.04),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${person.area}  •  ${person.department}',
                    maxLines: 1,
                    style: TextStyle(fontSize: h * 0.085, color: Colors.white70),
                  ),
                ),
                SizedBox(height: h * 0.03),
                Text(
                  maskNik(person.nik),
                  style: AppFonts.mono(
                    TextStyle(fontSize: h * 0.08, letterSpacing: 3, color: widget.accent.withValues(alpha: 0.9)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
