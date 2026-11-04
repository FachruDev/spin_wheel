import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/ui/format.dart';
import 'winner_report.dart';

enum WinnerPdfKind {
  daftar('Daftar pemenang', 'daftar_pemenang'),
  beritaAcara('Berita acara', 'berita_acara'),
  tandaTerima('Tanda terima per area', 'tanda_terima');

  const WinnerPdfKind(this.label, this.filePrefix);

  final String label;
  final String filePrefix;
}

/// Dokumen PDF hasil undian sesuai [kind].
Future<Uint8List> buildWinnersPdf(WinnerReport report, WinnerPdfKind kind) {
  final doc = pw.Document(
    title: '${kind.label} - ${pdfSafeText(report.event.name)}',
    author: pdfSafeText(report.organizationName),
    creator: 'Undian',
  );
  final builder = _WinnerPdf(report, kind);
  switch (kind) {
    case WinnerPdfKind.daftar:
      builder.addList(doc);
    case WinnerPdfKind.beritaAcara:
      builder.addMinutes(doc);
    case WinnerPdfKind.tandaTerima:
      builder.addReceipts(doc);
  }
  return doc.save();
}

/// Huruf berdiakritik di luar Latin-1 dan huruf dasarnya, mis. Ū → U.
const _accented = 'ĀāĂăĄąĆćČčĎďĒēĖėĘęĚěĞğĢģḤḥĪīĮįİıĶķĹĺĻļĽľŁłŃńŅņŇňŌōŐőŘřŚśŞşŠšŢţŤťŪūŮůŰűŲųŹźŻżŽž';
const _plain = 'AaAaAaCcCcDdEeEeEeEeGgGgHhIiIiIiKkLlLlLlLlNnNnNnOoOoRrSsSsSsTtTtUuUuUuUuZzZzZz';

/// Font standar PDF hanya mendukung huruf Latin-1. Huruf berdiakritik diganti huruf dasarnya,
/// huruf lain (mis. aksara non-Latin) diganti "?" agar dokumen tetap terbentuk.
String pdfSafeText(String text) {
  const punctuation = {'–': '-', '—': '-', '‘': "'", '’': "'", '“': '"', '”': '"'};
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    final accented = _accented.indexOf(char);
    buffer.write(punctuation[char] ?? (rune <= 0xFF ? char : (accented >= 0 ? _plain[accented] : '?')));
  }
  return buffer.toString();
}

/// Hanya PNG dan JPEG yang aman dibaca pembuat PDF; format lain dilewati.
pw.MemoryImage? _logoImage(Uint8List? bytes) {
  if (bytes == null || bytes.length < 4) return null;
  final png = bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
  final jpeg = bytes[0] == 0xFF && bytes[1] == 0xD8;
  return png || jpeg ? pw.MemoryImage(bytes) : null;
}

final _accent = PdfColor.fromInt(0xFF4F46E5);
final _stripe = PdfColor.fromInt(0xFFF3F4F6);
const _small = pw.TextStyle(fontSize: 8, color: PdfColors.grey700);
final _heading = pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
final _subheading = pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold);
const _body = pw.TextStyle(fontSize: 10, lineSpacing: 2);

class _WinnerPdf {
  _WinnerPdf(this.report, this.kind) : logo = _logoImage(report.logo);

  final WinnerReport report;
  final WinnerPdfKind kind;
  final pw.MemoryImage? logo;

  /// Tanggal acara bila diisi, selain itu tanggal dokumen dibuat.
  DateTime get _date => report.event.eventDate?.toLocal() ?? report.generatedAt;

  pw.MultiPage _page(List<pw.Widget> Function(pw.Context context) build) => pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(40, 32, 40, 32),
    maxPages: 500,
    header: _header,
    footer: _footer,
    build: build,
  );

  pw.Widget _header(pw.Context context) => pw.Column(
    children: [
      pw.Row(
        children: [
          if (logo case final image?) ...[
            pw.SizedBox(width: 36, height: 36, child: pw.Image(image, fit: pw.BoxFit.contain)),
            pw.SizedBox(width: 10),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(pdfSafeText(report.organizationName.toUpperCase()), style: _small),
                pw.Text(pdfSafeText(report.event.name), style: _subheading),
              ],
            ),
          ),
          pw.Text(kind.label, style: _small),
        ],
      ),
      pw.Divider(thickness: 0.5, color: PdfColors.grey500),
    ],
  );

  pw.Widget _footer(pw.Context context) => pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text('Dibuat ${formatDateTime(report.generatedAt)} dengan aplikasi Undian', style: _small),
      pw.Text('Halaman ${context.pageNumber} dari ${context.pagesCount}', style: _small),
    ],
  );

  pw.Widget _table(
    List<String> headers,
    List<List<String>> rows, {
    Map<int, pw.TableColumnWidth>? widths,
    double cellHeight = 0,
  }) => pw.TableHelper.fromTextArray(
    headers: headers,
    data: [
      for (final row in rows) [for (final cell in row) pdfSafeText(cell)],
    ],
    headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
    headerDecoration: pw.BoxDecoration(color: _accent),
    headerAlignment: pw.Alignment.centerLeft,
    cellStyle: const pw.TextStyle(fontSize: 9),
    cellAlignment: pw.Alignment.centerLeft,
    cellHeight: cellHeight,
    oddRowDecoration: pw.BoxDecoration(color: _stripe),
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    columnWidths: widths,
  );

  pw.Widget _title(String title) => pw.Column(
    children: [
      pw.Center(child: pw.Text(title, style: _heading)),
      pw.SizedBox(height: 2),
      pw.Center(child: pw.Text(formatLongDate(_date), style: _body)),
      pw.SizedBox(height: 14),
    ],
  );

  /// Daftar semua pemenang per hadiah, termasuk yang hangus/didiskualifikasi (ditandai di kolom status).
  void addList(pw.Document doc) {
    doc.addPage(
      _page(
        (context) => [
          _title('DAFTAR PEMENANG'),
          if (report.rows.isEmpty) pw.Text('Belum ada pemenang.', style: _body),
          for (final summary in report.summaries)
            if (report.rows.where((r) => r.prize.id == summary.prize.id).toList() case final rows
                when rows.isNotEmpty) ...[
              pw.Text(
                pdfSafeText(
                  '${summary.prize.name} (${prizeKindLabel(summary.prize.kind)}) - ${summary.valid} pemenang',
                ),
                style: _subheading,
              ),
              pw.SizedBox(height: 4),
              _table(
                ['No', 'NIK', 'Nama', 'Area', 'Departemen', 'Status'],
                [
                  for (final (i, r) in rows.indexed)
                    [
                      '${i + 1}',
                      r.participant.nik,
                      r.participant.name,
                      r.participant.area,
                      r.participant.department,
                      winnerStatusLabel(r.winner.status),
                    ],
                ],
                widths: const {0: pw.FixedColumnWidth(24), 1: pw.FixedColumnWidth(64)},
              ),
              pw.SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  /// Berita acara: uraian pelaksanaan, rekap hadiah, daftar pemenang sah, dan tanda tangan.
  void addMinutes(pw.Document doc) {
    final summaries = report.summaries;
    final valid = report.validRows;
    final forfeited = summaries.fold(0, (sum, s) => sum + s.forfeited);
    final disqualified = summaries.fold(0, (sum, s) => sum + s.disqualified);
    final units = report.prizes.fold(0, (sum, p) => sum + p.quantity);
    doc.addPage(
      _page(
        (context) => [
          _title('BERITA ACARA PENGUNDIAN HADIAH'),
          pw.Paragraph(
            style: _body,
            text: pdfSafeText(
              'Pada hari ini, ${formatLongDate(_date)}, telah dilaksanakan pengundian doorprize dan grand prize '
              'dalam acara "${report.event.name}" yang diselenggarakan oleh ${report.organizationName}. '
              'Pengundian dilakukan dengan aplikasi Undian: pemenang diacak oleh server dan setiap putaran '
              'tercatat dalam log audit.',
            ),
          ),
          pw.Paragraph(
            style: _body,
            text:
                'Jumlah peserta terdaftar ${report.participantCount} orang. Hadiah yang diundi ${report.prizes.length} '
                'jenis dengan total $units unit. Pemenang sah ${valid.length} orang'
                '${forfeited > 0 ? '; $forfeited pemenang dinyatakan hangus' : ''}'
                '${disqualified > 0 ? '; $disqualified pemenang didiskualifikasi dari hadiahnya' : ''}.',
          ),
          pw.Text('Rekapitulasi hadiah', style: _subheading),
          pw.SizedBox(height: 4),
          _table(
            ['No', 'Hadiah', 'Jenis', 'Unit', 'Sah', 'Hangus', 'Diskualifikasi', 'Sisa'],
            [
              for (final (i, s) in summaries.indexed)
                [
                  '${i + 1}',
                  s.prize.name,
                  prizeKindLabel(s.prize.kind),
                  '${s.prize.quantity}',
                  '${s.valid}',
                  '${s.forfeited}',
                  '${s.disqualified}',
                  '${s.remaining}',
                ],
            ],
            widths: const {0: pw.FixedColumnWidth(24)},
          ),
          pw.SizedBox(height: 14),
          pw.Text('Daftar pemenang sah', style: _subheading),
          pw.SizedBox(height: 4),
          if (valid.isEmpty)
            pw.Text('Belum ada pemenang sah.', style: _body)
          else
            _table(
              ['No', 'Hadiah', 'NIK', 'Nama', 'Area'],
              [
                for (final (i, r) in valid.indexed)
                  ['${i + 1}', r.prize.name, r.participant.nik, r.participant.name, r.participant.area],
              ],
              widths: const {0: pw.FixedColumnWidth(24), 2: pw.FixedColumnWidth(64)},
            ),
          pw.SizedBox(height: 14),
          pw.Paragraph(
            style: _body,
            text: 'Demikian berita acara ini dibuat dengan sebenarnya untuk dipergunakan sebagaimana mestinya.',
          ),
          pw.SizedBox(height: 10),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('........................., ${formatLongDate(_date)}', style: _body),
          ),
          pw.SizedBox(height: 12),
          _signatures(['Ketua Panitia', 'Saksi', 'Saksi']),
        ],
      ),
    );
  }

  /// Bukti tanda terima: halaman terpisah per area, dengan kolom tanda tangan penerima.
  void addReceipts(pw.Document doc) {
    final byArea = report.validRowsByArea;
    if (byArea.isEmpty) {
      doc.addPage(
        _page((context) => [_title('BUKTI TANDA TERIMA HADIAH'), pw.Text('Belum ada pemenang sah.', style: _body)]),
      );
      return;
    }
    for (final MapEntry(key: area, value: rows) in byArea.entries) {
      doc.addPage(
        _page(
          (context) => [
            _title('BUKTI TANDA TERIMA HADIAH'),
            pw.Text(pdfSafeText('Area: $area  (${rows.length} pemenang)'), style: _subheading),
            pw.SizedBox(height: 6),
            _table(
              ['No', 'Nama', 'NIK', 'Hadiah', 'Tanda tangan'],
              [
                for (final (i, r) in rows.indexed)
                  ['${i + 1}', r.participant.name, r.participant.nik, r.prize.name, ''],
              ],
              widths: const {
                0: pw.FixedColumnWidth(24),
                1: pw.FlexColumnWidth(3),
                2: pw.FixedColumnWidth(64),
                3: pw.FlexColumnWidth(3),
                4: pw.FlexColumnWidth(2),
              },
              cellHeight: 28,
            ),
            pw.SizedBox(height: 16),
            _signatures(['Petugas Penyerah', 'Mengetahui']),
          ],
        ),
      );
    }
  }

  pw.Widget _signatures(List<String> roles) => pw.Row(
    children: [
      for (final role in roles)
        pw.Expanded(
          child: pw.Column(
            children: [
              pw.Text(role, style: _body),
              pw.SizedBox(height: 48),
              pw.Text('(..............................)', style: _body),
            ],
          ),
        ),
    ],
  );
}
