const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// Tanggal singkat berbahasa Indonesia, mis. "3 Nov 2026".
String formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]} ${date.year}';

/// Tanggal dan jam, mis. "3 Nov 2026 19.05".
String formatDateTime(DateTime date) =>
    '${formatDate(date)} ${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
