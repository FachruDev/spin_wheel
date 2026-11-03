import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppFonts {
  /// Dimatikan di tes supaya tidak mengunduh font dari internet.
  static bool useGoogleFonts = true;

  static TextTheme textTheme(TextTheme base) => useGoogleFonts ? GoogleFonts.plusJakartaSansTextTheme(base) : base;

  /// Huruf untuk angka/NIK.
  static TextStyle mono(TextStyle style) => useGoogleFonts ? GoogleFonts.spaceGrotesk(textStyle: style) : style;
}
