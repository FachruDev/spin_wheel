import 'package:flutter/material.dart';
import 'package:undian_core/undian_core.dart';

import '../../../app/fonts.dart';

/// Ukuran desain layar panggung. Semua konten digambar di kanvas 16:9 ini lalu
/// diskalakan agar tampil sama di laptop maupun proyektor.
const kStageSize = Size(1920, 1080);

class StageCanvas extends StatelessWidget {
  const StageCanvas({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.contain,
    child: SizedBox.fromSize(size: kStageSize, child: child),
  );
}

/// Posisi [t] di antara [start] dan [end], dibatasi ke 0..1.
double interval(double t, double start, double end) => ((t - start) / (end - start)).clamp(0.0, 1.0);

/// NIK disamarkan di layar umum, mis. 23050057 → 2305••57.
String maskNik(String nik) {
  if (nik.length <= 6) return nik;
  return '${nik.substring(0, 4)}${'•' * (nik.length - 6)}${nik.substring(nik.length - 2)}';
}

String kindLabel(PrizeKind kind) => switch (kind) {
  PrizeKind.doorprize => 'DOORPRIZE',
  PrizeKind.grandprize => 'GRAND PRIZE',
};

/// Ikon hadiah dari namanya. Di versi penuh diganti foto hadiah yang diunggah.
IconData prizeIcon(Prize prize) {
  final name = prize.name.toLowerCase();
  if (name.contains('voucher')) return Icons.confirmation_number_rounded;
  if (name.contains('mixer')) return Icons.blender_rounded;
  if (name.contains('rice') || name.contains('magic com')) return Icons.rice_bowl_rounded;
  if (name.contains('tv')) return Icons.tv_rounded;
  if (name.contains('motor')) return Icons.two_wheeler_rounded;
  if (name.contains('mobil')) return Icons.directions_car_rounded;
  if (name.contains('emas') || name.contains('logam')) return Icons.diamond_rounded;
  if (name.contains('hp') || name.contains('smartphone')) return Icons.smartphone_rounded;
  return Icons.card_giftcard_rounded;
}

class StagePill extends StatelessWidget {
  const StagePill(this.label, {super.key, required this.color, this.fontSize = 22});

  final String label;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.9, vertical: fontSize * 0.4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, letterSpacing: 2, color: color),
      ),
    );
  }
}

/// Lingkaran bercahaya berisi ikon hadiah.
class PrizeBadge extends StatelessWidget {
  const PrizeBadge({super.key, required this.prize, required this.primary, required this.accent, this.size = 260});

  final Prize prize;
  final Color primary;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color.lerp(primary, Colors.white, 0.15)!, Color.lerp(primary, Colors.black, 0.55)!],
        ),
        border: Border.all(color: accent, width: size * 0.018),
        boxShadow: [
          BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: size * 0.35, spreadRadius: size * 0.02),
        ],
      ),
      child: Icon(prizeIcon(prize), size: size * 0.48, color: Colors.white),
    );
  }
}

/// Kartu besar pemenang untuk grand prize.
class WinnerSpotlightCard extends StatelessWidget {
  const WinnerSpotlightCard({
    super.key,
    required this.person,
    required this.prize,
    required this.primary,
    required this.accent,
    this.showFullNik = false,
  });

  final Participant person;
  final Prize prize;
  final Color primary;
  final Color accent;
  final bool showFullNik;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1400,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(primary, Colors.black, 0.2)!, Color.lerp(primary, Colors.black, 0.75)!],
        ),
        border: Border.all(color: accent, width: 3),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 90, spreadRadius: 6)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SELAMAT!',
            style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, letterSpacing: 20, color: accent),
          ),
          const SizedBox(height: 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              person.name,
              maxLines: 1,
              style: const TextStyle(fontSize: 124, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
            ),
          ),
          const SizedBox(height: 16),
          Text('${person.area}  •  ${person.department}', style: const TextStyle(fontSize: 40, color: Colors.white70)),
          const SizedBox(height: 12),
          Text(
            showFullNik ? person.nik : maskNik(person.nik),
            style: AppFonts.mono(TextStyle(fontSize: 38, letterSpacing: 6, color: accent)),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(prizeIcon(prize), size: 44, color: accent),
              const SizedBox(width: 16),
              Text(
                prize.name,
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
