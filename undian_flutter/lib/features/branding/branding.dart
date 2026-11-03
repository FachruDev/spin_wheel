import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BrandPalette {
  const BrandPalette(this.name, this.primary, this.accent);

  final String name;
  final Color primary;
  final Color accent;
}

const defaultPalette = BrandPalette('Malam Emas', Color(0xFF4F46E5), Color(0xFFF5C04E));

const brandPalettes = [
  defaultPalette,
  BrandPalette('Biru Korporat', Color(0xFF1D64F2), Color(0xFF38E1FF)),
  BrandPalette('Hijau Segar', Color(0xFF0E9F6E), Color(0xFFC6F432)),
  BrandPalette('Merah Meriah', Color(0xFFE11D48), Color(0xFFFFC53D)),
  BrandPalette('Ungu Neon', Color(0xFF7C3AED), Color(0xFFFF6AD5)),
];

/// Identitas organisasi yang tampil di aplikasi dan layar panggung.
///
/// Aplikasi dipakai banyak perusahaan, jadi tidak ada nama atau logo yang ditulis mati.
/// Di versi penuh, nilai ini disimpan per organisasi di server.
class Branding {
  const Branding({
    this.organizationName = 'Nama Perusahaan',
    this.eventTitle = 'Undian Doorprize & Grand Prize',
    this.palette = defaultPalette,
    this.logoBytes,
  });

  final String organizationName;
  final String eventTitle;
  final BrandPalette palette;
  final Uint8List? logoBytes;

  Color get primary => palette.primary;
  Color get accent => palette.accent;

  /// Inisial untuk logo pengganti, mis. "Maju Bersama Sejahtera" → "MB".
  String get initials {
    final words = organizationName.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = words.take(2).map((w) => w[0].toUpperCase()).join();
    return letters.isEmpty ? '?' : letters;
  }

  static const _keep = Object();

  Branding copyWith({String? organizationName, String? eventTitle, BrandPalette? palette, Object? logoBytes = _keep}) =>
      Branding(
        organizationName: organizationName ?? this.organizationName,
        eventTitle: eventTitle ?? this.eventTitle,
        palette: palette ?? this.palette,
        logoBytes: identical(logoBytes, _keep) ? this.logoBytes : logoBytes as Uint8List?,
      );
}

final brandingProvider = NotifierProvider<BrandingController, Branding>(BrandingController.new);

class BrandingController extends Notifier<Branding> {
  @override
  Branding build() => const Branding();

  void update(Branding branding) => state = branding;
}
