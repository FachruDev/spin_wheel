import 'package:excel/excel.dart' as xl;

import '../../../core/excel/excel_sheet.dart';

/// Judul kolom template. Harus dikenali otomatis oleh guessMapping (dijaga oleh tes).
const templateHeaders = [
  'NIK',
  'Nama',
  'Area',
  'Departemen',
  'Status Karyawan',
  'No HP',
  'Poin',
  'Grup 1',
  'Grup 2',
  'Grup 3',
];

const _columnWidths = [16.0, 32.0, 20.0, 20.0, 18.0, 16.0, 8.0, 22.0, 22.0, 22.0];

/// Contoh pengisian; nama dan nomor fiktif.
const _examples = [
  [
    '03090234',
    'Andi Pratama',
    'Bogor Plant',
    'Produksi',
    'Pegawai Tetap',
    '081200000001',
    '',
    'Doorprize Bogor',
    'Grandprize Bogor',
    '',
  ],
  [
    '04090246',
    'Siti Rahmawati',
    'Head Office',
    'Finance',
    'Pegawai Tetap',
    '',
    '2',
    'Doorprize Jakarta',
    'Grandprize Jakarta',
    '',
  ],
  ['16063404', 'Budi Santoso', 'Head Office', 'ICT', 'Kontrak 1', '', '', 'Doorprize Jakarta', '', ''],
  [
    '21104567',
    'Dewi Lestari',
    'Bogor Plant',
    'Quality Control',
    'Percobaan',
    '',
    '',
    'Doorprize Bogor, Grandprize Bogor',
    '',
    '',
  ],
];

const _instructions = [
  'PETUNJUK PENGISIAN DATA PESERTA UNDIAN',
  '',
  '1. Isi data di sheet "Peserta": satu baris untuk satu orang, mulai baris 2. Jangan mengubah baris judul.',
  '2. Kolom WAJIB: NIK dan Nama. NIK adalah nomor induk karyawan sekaligus nomor undian, dan harus unik.',
  '3. Kolom NIK sudah berformat Teks supaya angka nol di depan (mis. 03090234) tidak hilang. '
      'Bila menyalin dari file lain, pakai Tempel Khusus > Nilai (Paste Special > Values).',
  '4. Area, Departemen, Status Karyawan, dan No HP boleh kosong. Area dan Departemen tampil di layar panggung.',
  '5. Poin boleh kosong (dianggap 1). Poin 2 berarti peluang menang 2 kali lipat, poin 3 berarti 3 kali lipat.',
  '6. Grup menentukan hadiah yang bisa diikuti peserta, mis. "Doorprize Bogor" atau "Grandprize Jakarta".',
  '   - Tulis nama grup persis sama untuk semua peserta (huruf besar/kecil dan spasi harus sama).',
  '   - Satu peserta boleh punya beberapa grup: isi Grup 1, Grup 2, Grup 3, atau pisahkan dengan koma dalam satu sel.',
  '   - Kolom grup boleh ditambah (Grup 4, Grup 5, dan seterusnya).',
  '   - Peserta yang tidak berhak grand prize cukup tidak diberi grup grand prize.',
  '7. Lihat sheet "Contoh" untuk contoh pengisian. Jangan menaruh data asli di sheet Contoh.',
  '8. Simpan sebagai .xlsx, lalu di aplikasi: buka acara > tab Peserta > Import Excel > pilih file ini.',
  '   Kolom akan dicocokkan otomatis; periksa pratinjau sebelum menekan Import.',
];

/// Template Excel kosong untuk data peserta, dengan sheet Peserta, Contoh, dan Petunjuk.
/// [preformattedRows] baris di sheet Peserta yang kolom NIK-nya sudah berformat Teks.
List<int> buildParticipantTemplate({int preformattedRows = 1000}) {
  final book = xl.Excel.createExcel();
  final defaultName = book.getDefaultSheet()!;
  book.rename(defaultName, 'Peserta');
  final participants = book['Peserta'];
  writeExcelHeader(participants, templateHeaders, _columnWidths);
  for (var row = 1; row <= preformattedRows; row++) {
    participants.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).cellStyle = excelTextStyle;
  }

  final examples = book['Contoh'];
  writeExcelHeader(examples, templateHeaders, _columnWidths);
  writeExcelRows(examples, _examples, textColumns: const {0});

  final help = book['Petunjuk'];
  help.setColumnWidth(0, 120);
  for (var i = 0; i < _instructions.length; i++) {
    final cell = help.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i));
    cell.value = xl.TextCellValue(_instructions[i]);
    cell.cellStyle = xl.CellStyle(bold: i == 0, fontSize: i == 0 ? 14 : null, textWrapping: xl.TextWrapping.WrapText);
  }

  book.setDefaultSheet('Peserta');
  return book.encode()!;
}
