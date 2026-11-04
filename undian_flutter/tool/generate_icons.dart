// Menggambar ikon aplikasi "Undian" (kotak hadiah emas di atas latar indigo) tanpa file sumber:
// semua bentuk didefinisikan sebagai fungsi jarak, jadi tiap ukuran digambar tajam dan halus.
//
//   dart run tool/generate_icons.dart                 → ikon Windows (.ico) dan ikon web (.png)
//   dart run tool/generate_icons.dart --wizard <dir>  → gambar wizard installer (.bmp)
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Warna mengikuti palet bawaan aplikasi "Malam Emas" (indigo #4F46E5 + emas #F5C04E).
const _indigoLight = _Rgb(0x75, 0x6C, 0xF8);
const _indigoDark = _Rgb(0x3F, 0x35, 0xC4);
const _gold = _Rgb(0xF5, 0xC0, 0x4E);
const _goldDeep = _Rgb(0xDF, 0xA3, 0x35);
const _goldLight = _Rgb(0xFA, 0xD2, 0x72);
const _white = _Rgb(0xFF, 0xFF, 0xFF);
const _lavender = _Rgb(0xEA, 0xE8, 0xFF);
const _black = _Rgb(0x10, 0x0C, 0x30);

/// Ruang gambar ikon: 1024 × 1024 satuan, titik (0, 0) di kiri atas.
const _design = 1024.0;

void main(List<String> args) {
  final wizardAt = args.indexOf('--wizard');
  if (wizardAt >= 0) {
    if (wizardAt + 1 >= args.length) {
      stderr.writeln('Pakai: dart run tool/generate_icons.dart --wizard <folder>');
      exitCode = 64;
      return;
    }
    _writeWizardImages(args[wizardAt + 1]);
    return;
  }

  final ico = _icoFile([for (final s in [16, 20, 24, 32, 40, 48, 64, 128, 256]) _appIcon(s)]);
  _write('windows/runner/resources/app_icon.ico', ico);
  _write('web/favicon.png', img.encodePng(_appIcon(32)));
  for (final s in [192, 512]) {
    _write('web/icons/Icon-$s.png', img.encodePng(_appIcon(s)));
    _write('web/icons/Icon-maskable-$s.png', img.encodePng(_maskableIcon(s)));
  }
}

/// Ikon utama: latar kotak membulat (sudut transparan) dan kotak hadiah.
img.Image _appIcon(int size) => _render(
  size,
  size,
  [_Layer(_roundedBackground, _diagonalGradient), ..._giftLayers()],
  unitsPerPixel: _design / size,
);

/// Ikon "maskable" untuk Android/PWA: latar penuh, isi di dalam zona aman 80%.
img.Image _maskableIcon(int size) {
  const shrink = 1.12; // isi sedikit diperkecil supaya tidak terpotong mask lingkaran
  final upp = _design * shrink / size;
  final origin = (_design - size * upp) / 2;
  return _render(
    size,
    size,
    [_Layer(_everywhere, _diagonalGradient), ..._giftLayers()],
    unitsPerPixel: upp,
    originX: origin,
    originY: origin,
  );
}

/// Gambar wizard Inno Setup (BMP 24-bit) untuk skala layar 100%, 150%, dan 200%.
void _writeWizardImages(String dir) {
  const scales = {100: 1.0, 150: 1.5, 200: 2.0};
  for (final MapEntry(key: pct, value: k) in scales.entries) {
    // Panel kiri halaman sambutan & selesai (164 × 314 pada 100%).
    final w = (164 * k).round(), h = (314 * k).round();
    final upp = 560 / (w * 0.72); // lebar hadiah ±72% lebar panel
    final originX = _giftCenterX - w * upp / 2;
    final originY = _giftCenterY - h * 0.42 * upp;
    final panelHeight = h * upp;
    final panel = _render(
      w,
      h,
      [
        _Layer(_everywhere, (x, y) => _indigoLight.mix(_indigoDark, ((y - originY) / panelHeight).clamp(0.0, 1.0))),
        ..._giftLayers(),
      ],
      unitsPerPixel: upp,
      originX: originX,
      originY: originY,
      opaque: true,
    );
    _write('$dir/wizard-$pct.bmp', _bmpFile(panel));

    // Ikon kecil di kanan atas halaman lain (55 × 58 pada 100%), latar putih.
    final sw = (55 * k).round(), sh = (58 * k).round();
    final iconPx = math.min(sw, sh) * 0.92;
    final supp = _design / iconPx;
    final small = _render(
      sw,
      sh,
      [_Layer(_roundedBackground, _diagonalGradient), ..._giftLayers()],
      unitsPerPixel: supp,
      originX: -(sw - iconPx) / 2 * supp,
      originY: -(sh - iconPx) / 2 * supp,
      opaque: true,
      backdrop: _white,
    );
    _write('$dir/wizard-small-$pct.bmp', _bmpFile(small));
  }
}

// ---------------------------------------------------------------------------------------------
// Bentuk kotak hadiah (satuan ruang gambar 1024).

const _giftCenterX = 512.0;
const _giftCenterY = 532.0;

double _lid(double x, double y) => _box(x, y, 512, 470, 256, 56, 30);
double _body(double x, double y) => _box(x, y, 512, 672, 214, 136, 30);
double _ribbonBand(double x, double y) => (x - 512).abs() - 34;

double _bowLoops(double x, double y) => math.min(
  _ellipseRing(x, y, 414, 346, 108, 66, 0.56, 40),
  _ellipseRing(x, y, 610, 346, 108, 66, -0.56, 40),
);
double _knot(double x, double y) => _box(x, y, 512, 410, 44, 38, 24);

List<_Layer> _giftLayers() => [
  // Bayangan lembut di bawah kotak.
  _Layer((x, y) => math.min(_lid(x, y - 30), _body(x, y - 30)), (x, y) => _black, opacity: 0.28, blur: 56),
  _Layer(_bowLoops, (x, y) => _gold),
  _Layer(_lid, (x, y) => _white),
  _Layer((x, y) => math.max(_lid(x, y), _ribbonBand(x, y)), (x, y) => _gold),
  _Layer(_body, (x, y) => _lavender),
  _Layer((x, y) => math.max(_body(x, y), _ribbonBand(x, y)), (x, y) => _goldDeep),
  _Layer(_knot, (x, y) => _goldLight),
];

double _roundedBackground(double x, double y) => _box(x, y, 512, 512, 472, 472, 216);

/// Latar penuh: jarak sangat negatif supaya tertutup 100% di skala berapa pun.
double _everywhere(double x, double y) => -1e9;

_Rgb _diagonalGradient(double x, double y) =>
    _indigoLight.mix(_indigoDark, ((x + y) / (2 * _design)).clamp(0.0, 1.0));

// ---------------------------------------------------------------------------------------------
// Fungsi jarak bertanda: negatif di dalam bentuk, positif di luar.

/// Kotak membulat dengan pusat (cx, cy), setengah lebar/tinggi (hw, hh), dan jari-jari sudut r.
double _box(double x, double y, double cx, double cy, double hw, double hh, double r) {
  final qx = (x - cx).abs() - hw + r;
  final qy = (y - cy).abs() - hh + r;
  final ox = math.max(qx, 0.0), oy = math.max(qy, 0.0);
  return math.sqrt(ox * ox + oy * oy) + math.min(math.max(qx, qy), 0.0) - r;
}

/// Cincin elips (pita simpul) dengan sumbu a × b yang diputar [angle] radian.
double _ellipseRing(double x, double y, double cx, double cy, double a, double b, double angle, double thickness) {
  final dx = x - cx, dy = y - cy;
  final c = math.cos(angle), s = math.sin(angle);
  final u = dx * c + dy * s, v = -dx * s + dy * c;
  final k = math.sqrt((u * u) / (a * a) + (v * v) / (b * b));
  final grad = math.sqrt(math.pow(u / (a * a), 2) + math.pow(v / (b * b), 2)) / math.max(k, 1e-9);
  final d = (k - 1) / math.max(grad, 1e-9);
  return d.abs() - thickness / 2;
}

// ---------------------------------------------------------------------------------------------
// Rasterisasi.

class _Rgb {
  const _Rgb(this.r, this.g, this.b);
  final double r, g, b;

  _Rgb mix(_Rgb o, double t) => _Rgb(r + (o.r - r) * t, g + (o.g - g) * t, b + (o.b - b) * t);
}

class _Layer {
  const _Layer(this.distance, this.color, {this.opacity = 1, this.blur = 0});

  final double Function(double x, double y) distance;
  final _Rgb Function(double x, double y) color;
  final double opacity;

  /// Lebar tepi lembut (satuan ruang gambar); 0 = tepi tajam satu piksel.
  final double blur;
}

/// Menggambar [layers] berurutan ke gambar [width] × [height]. Piksel (px, py) dipetakan ke
/// titik ruang gambar (originX + (px + 0.5) × unitsPerPixel, …).
img.Image _render(
  int width,
  int height,
  List<_Layer> layers, {
  required double unitsPerPixel,
  double originX = 0,
  double originY = 0,
  bool opaque = false,
  _Rgb backdrop = _white,
}) {
  final out = img.Image(width: width, height: height, numChannels: opaque ? 3 : 4);
  for (var py = 0; py < height; py++) {
    final y = originY + (py + 0.5) * unitsPerPixel;
    for (var px = 0; px < width; px++) {
      final x = originX + (px + 0.5) * unitsPerPixel;
      var r = backdrop.r, g = backdrop.g, b = backdrop.b;
      var a = opaque ? 1.0 : 0.0;
      for (final layer in layers) {
        final d = layer.distance(x, y);
        final edge = layer.blur > 0 ? layer.blur : unitsPerPixel;
        final cover = (0.5 - d / edge).clamp(0.0, 1.0) * layer.opacity;
        if (cover <= 0) continue;
        final c = layer.color(x, y);
        final outA = cover + a * (1 - cover);
        r = (c.r * cover + r * a * (1 - cover)) / outA;
        g = (c.g * cover + g * a * (1 - cover)) / outA;
        b = (c.b * cover + b * a * (1 - cover)) / outA;
        a = outA;
      }
      if (opaque) {
        out.setPixelRgb(px, py, r.round(), g.round(), b.round());
      } else {
        out.setPixelRgba(px, py, r.round(), g.round(), b.round(), (a * 255).round());
      }
    }
  }
  return out;
}

/// Berkas .ico berisi beberapa ukuran, tiap ukuran disimpan sebagai PNG (didukung sejak Windows Vista).
List<int> _icoFile(List<img.Image> images) {
  final pngs = [for (final image in images) img.encodePng(image)];
  final header = BytesBuilder()..add(_le16(0))..add(_le16(1))..add(_le16(images.length));
  var offset = 6 + 16 * images.length;
  for (var i = 0; i < images.length; i++) {
    final image = images[i];
    header
      ..addByte(image.width >= 256 ? 0 : image.width)
      ..addByte(image.height >= 256 ? 0 : image.height)
      ..addByte(0) // tanpa palet
      ..addByte(0)
      ..add(_le16(1)) // bidang warna
      ..add(_le16(32)) // bit per piksel
      ..add(_le32(pngs[i].length))
      ..add(_le32(offset));
    offset += pngs[i].length;
  }
  for (final png in pngs) {
    header.add(png);
  }
  return header.takeBytes();
}

/// BMP 24-bit tanpa kompresi (BI_RGB), format yang dibaca Inno Setup. Encoder bawaan paket
/// image menulis BI_BITFIELDS, yang tidak sah untuk 24-bit.
List<int> _bmpFile(img.Image image) {
  final w = image.width, h = image.height;
  final stride = (w * 3 + 3) & ~3;
  final pixelBytes = stride * h;
  final out = BytesBuilder()
    ..add([0x42, 0x4D]) // "BM"
    ..add(_le32(54 + pixelBytes))
    ..add(_le32(0))
    ..add(_le32(54)) // awal data piksel
    ..add(_le32(40)) // BITMAPINFOHEADER
    ..add(_le32(w))
    ..add(_le32(h)) // positif = baris dari bawah ke atas
    ..add(_le16(1))
    ..add(_le16(24))
    ..add(_le32(0)) // BI_RGB
    ..add(_le32(pixelBytes))
    ..add(_le32(2835)) // 72 dpi
    ..add(_le32(2835))
    ..add(_le32(0))
    ..add(_le32(0));
  final row = Uint8List(stride);
  for (var y = h - 1; y >= 0; y--) {
    for (var x = 0; x < w; x++) {
      final p = image.getPixel(x, y);
      row[x * 3] = p.b.toInt();
      row[x * 3 + 1] = p.g.toInt();
      row[x * 3 + 2] = p.r.toInt();
    }
    out.add(row);
  }
  return out.takeBytes();
}

List<int> _le16(int v) => [v & 0xFF, (v >> 8) & 0xFF];
List<int> _le32(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];

void _write(String path, List<int> bytes) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes);
  stdout.writeln('Tersimpan: $path');
}
