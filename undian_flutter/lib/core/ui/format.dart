const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

const _longMonths = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

/// Tanggal singkat berbahasa Indonesia, mis. "3 Nov 2026".
String formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]} ${date.year}';

/// Tanggal dan jam, mis. "3 Nov 2026 19.05".
String formatDateTime(DateTime date) => '${formatDate(date)} ${formatTime(date)}';

/// Jam, mis. "19.05".
String formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';

/// Tanggal lengkap untuk dokumen resmi, mis. "Selasa, 3 November 2026".
String formatLongDate(DateTime date) =>
    '${_days[date.weekday - 1]}, ${date.day} ${_longMonths[date.month - 1]} ${date.year}';

/// Nama file yang aman dari teks bebas, mis. "HUT 2026 (Demo)" → "hut_2026_demo".
String fileSlug(String text) {
  final slug = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
  return slug.isEmpty ? 'undian' : slug;
}
