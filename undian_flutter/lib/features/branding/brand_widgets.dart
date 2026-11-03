import 'package:flutter/material.dart';

import 'branding.dart';

/// Logo organisasi; jika belum diunggah, tampil inisial dengan warna tema.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, required this.branding, this.size = 72});

  final Branding branding;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.26);
    final logo = branding.logoBytes;
    if (logo != null) {
      return Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.1),
        decoration: BoxDecoration(color: Colors.white, borderRadius: radius),
        child: Image.memory(logo, fit: BoxFit.contain),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [branding.primary, branding.accent],
        ),
      ),
      child: Text(
        branding.initials,
        style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.w800, color: Colors.white),
      ),
    );
  }
}

/// Logo + nama organisasi + judul acara di pojok kiri atas layar panggung.
class StageHeader extends StatelessWidget {
  const StageHeader({super.key, required this.branding});

  final Branding branding;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandLogo(branding: branding, size: 84),
        const SizedBox(width: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branding.organizationName.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 6, color: branding.accent),
              ),
              Text(
                branding.eventTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
