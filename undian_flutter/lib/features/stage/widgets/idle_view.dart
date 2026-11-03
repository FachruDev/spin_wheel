import 'package:flutter/material.dart';
import 'package:undian_core/undian_core.dart';

import '../../branding/branding.dart';
import 'common.dart';

/// Layar jeda: hadiah berikutnya beserta stok dan jumlah peserta yang berhak.
class IdleView extends StatefulWidget {
  const IdleView({
    super.key,
    required this.branding,
    required this.prize,
    required this.remaining,
    required this.eligibleCount,
  });

  final Branding branding;
  final Prize? prize;
  final int remaining;
  final int eligibleCount;

  @override
  State<IdleView> createState() => _IdleViewState();
}

class _IdleViewState extends State<IdleView> with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prize = widget.prize;
    final accent = widget.branding.accent;
    if (prize == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.branding.eventTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('Pilih hadiah di panel operator', style: TextStyle(fontSize: 36, color: Colors.white60)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 150, left: 80, right: 80),
      child: Center(
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HADIAH BERIKUTNYA',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: 14, color: accent),
              ),
              const SizedBox(height: 24),
              SizedBox.square(
                dimension: 440,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var k = 0; k < 3; k++) _ring((_pulse.value + k / 3) % 1, accent),
                    PrizeBadge(prize: prize, primary: widget.branding.primary, accent: accent, size: 250),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                prize.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(fontSize: 92, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  StagePill(kindLabel(prize.kind), color: accent),
                  StagePill('SISA ${widget.remaining} DARI ${prize.quantity} UNIT', color: Colors.white),
                  StagePill('${widget.eligibleCount} PESERTA BERHAK', color: Colors.white),
                ],
              ),
              const SizedBox(height: 56),
              Opacity(
                opacity: 0.45 + 0.55 * (0.5 + 0.5 * (1 - (2 * _pulse.value - 1).abs())),
                child: Text(
                  widget.remaining > 0 ? 'Tekan SPASI untuk mengundi' : 'Semua unit sudah terundi',
                  style: const TextStyle(fontSize: 32, color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ring(double t, Color color) => Container(
    width: 250 + 190 * t,
    height: 250 + 190 * t,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color.withValues(alpha: 0.5 * (1 - t)), width: 3),
    ),
  );
}
