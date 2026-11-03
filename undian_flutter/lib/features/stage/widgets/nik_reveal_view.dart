import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:undian_core/undian_core.dart';

import '../../../app/fonts.dart';
import 'common.dart';
import 'confetti.dart';

/// Animasi grand prize "Buka NIK": tiap digit nomor undian berputar lalu berhenti
/// satu per satu dari kiri. Di bawahnya terlihat sisa kandidat yang nomornya masih cocok.
class NikRevealView extends StatefulWidget {
  const NikRevealView({
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
  State<NikRevealView> createState() => _NikRevealViewState();
}

class _NikRevealViewState extends State<NikRevealView> with SingleTickerProviderStateMixin {
  // Lini waktu dalam milidetik.
  static const _spinStart = 1200.0;
  static const _firstLock = 2800.0;
  static const _lockGap = 1000.0;
  static const _decel = 700.0;

  /// Kecepatan putar digit (angka per detik).
  static const _velocity = 14.0;
  static const _slotWidth = 150.0;
  static const _slotHeight = 210.0;

  late final String _nik = widget.winner.nik;

  /// Digit per karakter NIK; null untuk karakter bukan angka (ditampilkan diam).
  late final List<int?> _digits = [for (final ch in _nik.split('')) int.tryParse(ch)];
  late final List<double> _lockAt;
  late final List<double> _phase;
  late final double _revealAt;
  late final double _total;
  late final AnimationController _controller;
  var _confetti = false;

  @override
  void initState() {
    super.initState();
    _lockAt = List.filled(_digits.length, 0);
    _phase = List.filled(_digits.length, 0);
    var order = 0;
    for (var i = 0; i < _digits.length; i++) {
      final digit = _digits[i];
      if (digit == null) continue;
      _lockAt[i] = _firstLock + order++ * _lockGap;
      // Fase awal dipilih supaya putaran yang melambat berhenti tepat di digit pemenang.
      final lock = (_lockAt[i] - _spinStart) / 1000;
      _phase[i] = (digit - _velocity * (lock - _decel / 2000)) % 10;
    }
    _revealAt = _firstLock + math.max(0, order - 1) * _lockGap + 800;
    _total = _revealAt + 1800;
    _controller =
        AnimationController(
          vsync: this,
          duration: Duration(milliseconds: _total.round()),
        )..addListener(() {
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

  /// Posisi gulungan digit ke-[i] (satuan angka): konstan, lalu melambat rata selama
  /// [_decel] hingga berhenti di [_lockAt].
  double _position(int i, double e) {
    final t = (e - _spinStart) / 1000;
    if (t <= 0) return _phase[i];
    final lock = (_lockAt[i] - _spinStart) / 1000;
    const decel = _decel / 1000;
    if (t <= lock - decel) return _phase[i] + _velocity * t;
    final tau = math.min(t, lock) - (lock - decel);
    return _phase[i] + _velocity * (lock - decel) + _velocity * tau - _velocity * tau * tau / (2 * decel);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final e = _controller.value * _total;
        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - 0.85 * interval(e, _revealAt, _revealAt + 500),
              child: Column(
                children: [
                  const SizedBox(height: 185),
                  Opacity(
                    opacity: interval(e, 0, 600),
                    child: Text(
                      'GRAND PRIZE',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 16,
                        color: widget.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: interval(e, 150, 750),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(prizeIcon(widget.prize), size: 60, color: widget.accent),
                        const SizedBox(width: 20),
                        Text(
                          widget.prize.name,
                          style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                  Opacity(
                    opacity: interval(e, 400, 1000),
                    child: const Text('Nomor undian pemenang', style: TextStyle(fontSize: 34, color: Colors.white60)),
                  ),
                  const SizedBox(height: 30),
                  Opacity(
                    opacity: interval(e, 600, 1200),
                    child: SizedBox(
                      width: 1700,
                      height: _slotHeight * 1.15,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            for (var i = 0; i < _digits.length; i++) ...[
                              if (i > 0) const SizedBox(width: 18),
                              _slot(i, e),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (e < _revealAt) _candidates(e),
                ],
              ),
            ),
            if (e >= _revealAt) Positioned.fill(key: const ValueKey('reveal'), child: _reveal(e)),
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

  Widget _slot(int i, double e) {
    final digit = _digits[i];
    if (digit == null) {
      return Text(_nik[i], style: AppFonts.mono(const TextStyle(fontSize: 120, color: Colors.white54)));
    }
    final locked = e >= _lockAt[i];
    final bounce = locked ? math.sin(math.pi * interval(e, _lockAt[i], _lockAt[i] + 380)) : 0.0;
    final Widget content;
    if (locked) {
      content = Center(child: _digitText(digit, widget.accent));
    } else {
      final position = _position(i, e);
      final base = position.floor();
      final frac = position - base;
      content = Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: -frac * _slotHeight,
            height: _slotHeight,
            child: Center(child: _digitText(base % 10, Colors.white70)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: (1 - frac) * _slotHeight,
            height: _slotHeight,
            child: Center(child: _digitText((base + 1) % 10, Colors.white70)),
          ),
        ],
      );
    }
    return Transform.scale(
      scale: 1 + 0.12 * bounce,
      child: Container(
        width: _slotWidth,
        height: _slotHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: locked
                ? [Color.lerp(widget.primary, Colors.black, 0.2)!, Color.lerp(widget.primary, Colors.black, 0.7)!]
                : [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.03)],
          ),
          border: Border.all(color: locked ? widget.accent : Colors.white24, width: locked ? 3 : 1.5),
          boxShadow: locked ? [BoxShadow(color: widget.accent.withValues(alpha: 0.4), blurRadius: 36)] : null,
        ),
        child: content,
      ),
    );
  }

  Widget _digitText(int digit, Color color) => Text(
    '$digit',
    style: AppFonts.mono(TextStyle(fontSize: 132, fontWeight: FontWeight.w700, color: color, height: 1)),
  );

  /// Jumlah peserta berhak yang nomornya masih cocok dengan digit yang sudah terbuka.
  Widget _candidates(double e) {
    final prefix = StringBuffer();
    for (var i = 0; i < _digits.length; i++) {
      if (_digits[i] != null && e < _lockAt[i]) break;
      prefix.write(_nik[i]);
    }
    final count = widget.pool.where((p) => p.nik.startsWith(prefix.toString())).length;
    final last = count == 1 && prefix.isNotEmpty;
    return Opacity(
      opacity: interval(e, 800, 1400),
      child: Column(
        children: [
          Text(
            last ? 'Tinggal satu nama…' : '$count kandidat',
            style: AppFonts.mono(
              TextStyle(fontSize: 60, fontWeight: FontWeight.w700, color: last ? widget.accent : Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          const Text('peserta berhak yang nomornya masih cocok', style: TextStyle(fontSize: 26, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _reveal(double e) {
    final t = Curves.easeOutCubic.transform(interval(e, _revealAt, _revealAt + 800));
    return Center(
      child: Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 160 * (1 - t)),
          child: WinnerSpotlightCard(
            person: widget.winner,
            prize: widget.prize,
            primary: widget.primary,
            accent: widget.accent,
            showFullNik: true,
          ),
        ),
      ),
    );
  }
}
