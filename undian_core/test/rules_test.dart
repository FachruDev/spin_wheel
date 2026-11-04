import 'package:test/test.dart';
import 'package:undian_core/undian_core.dart';

void main() {
  group('planImport', () {
    test('merapikan baris sah dan menolak yang bermasalah', () {
      final plan = UndianRules.planImport(const [
        ImportRow(nik: ' 001 ', name: ' Ani ', area: ' Bogor ', groups: [' B ', 'A', 'B', '']),
        ImportRow(nik: '', name: 'Tanpa NIK'),
        ImportRow(nik: '002', name: '  '),
        ImportRow(nik: '003', name: 'Budi', points: 0),
        ImportRow(nik: '001', name: 'Ani lagi'),
      ]);
      expect(plan.valid.keys, ['001']);
      final ani = plan.valid['001']!;
      expect((ani.nik, ani.name, ani.area), ('001', 'Ani', 'Bogor'));
      expect(ani.groups, ['A', 'B']);
      expect(plan.rejected, [
        'Baris 2: NIK kosong',
        'Baris 3 (002): nama kosong',
        'Baris 4 (003): poin harus minimal 1',
        'Baris 5: NIK 001 muncul lebih dari sekali',
      ]);
    });
  });

  group('hadiah', () {
    test('nama, jumlah, dan grup wajib', () {
      expect(UndianRules.prizeProblem(name: ' ', quantity: 1, openToAll: true, groups: []), 'Nama hadiah wajib diisi.');
      expect(UndianRules.prizeProblem(name: 'TV', quantity: 0, openToAll: true, groups: []), 'Jumlah unit minimal 1.');
      expect(
        UndianRules.prizeProblem(name: 'TV', quantity: 1, openToAll: false, groups: []),
        contains('minimal satu grup'),
      );
      expect(UndianRules.prizeProblem(name: 'TV', quantity: 1, openToAll: false, groups: ['A']), isNull);
      expect(UndianRules.prizeProblem(name: 'TV', quantity: 1, openToAll: true, groups: []), isNull);
    });

    test('jumlah tidak boleh kurang dari unit terundi', () {
      expect(UndianRules.prizeQuantityProblem(quantity: 2, used: 3), contains('Sudah 3 unit terundi'));
      expect(UndianRules.prizeQuantityProblem(quantity: 3, used: 3), isNull);
    });
  });

  group('status pemenang', () {
    test('hangus wajib beralasan dan final', () {
      expect(
        UndianRules.statusChangeProblem(current: WinnerStatus.sah, next: WinnerStatus.hangus, note: ' '),
        'Alasan wajib diisi untuk menandai hangus.',
      );
      expect(
        UndianRules.statusChangeProblem(current: WinnerStatus.hangus, next: WinnerStatus.sah),
        'Pemenang yang sudah hangus tidak bisa diubah statusnya.',
      );
      expect(UndianRules.statusChangeProblem(current: WinnerStatus.sah, next: WinnerStatus.diserahkan), isNull);
      expect(
        UndianRules.statusChangeProblem(current: WinnerStatus.sah, next: WinnerStatus.hangus, note: 'Tidak hadir'),
        isNull,
      );
    });

    test('diskualifikasi wajib beralasan dan final', () {
      expect(
        UndianRules.statusChangeProblem(current: WinnerStatus.sah, next: WinnerStatus.diskualifikasi),
        'Alasan wajib diisi untuk mendiskualifikasi pemenang.',
      );
      expect(
        UndianRules.statusChangeProblem(
          current: WinnerStatus.diserahkan,
          next: WinnerStatus.diskualifikasi,
          note: 'Bukan karyawan area Bogor',
        ),
        isNull,
      );
      expect(
        UndianRules.statusChangeProblem(current: WinnerStatus.diskualifikasi, next: WinnerStatus.sah),
        'Pemenang yang sudah didiskualifikasi tidak bisa diubah statusnya.',
      );
    });
  });

  test('peserta dari formulir', () {
    expect(UndianRules.participantProblem(const ImportRow(nik: '', name: 'Ani')), 'NIK wajib diisi.');
    expect(UndianRules.participantProblem(const ImportRow(nik: '1', name: '')), 'Nama peserta wajib diisi.');
    expect(UndianRules.participantProblem(const ImportRow(nik: '1', name: 'Ani', points: 0)), 'Poin minimal 1.');
    expect(UndianRules.participantProblem(const ImportRow(nik: '1', name: 'Ani')), isNull);
  });

  test('putaran, jumlah per putaran, logo, nama', () {
    expect(UndianRules.nextRoundNo([]), 1);
    expect(UndianRules.nextRoundNo([1, 3, 2]), 4);
    expect(UndianRules.drawCountProblem(0), isNotNull);
    expect(UndianRules.drawCountProblem(51), isNotNull);
    expect(UndianRules.drawCountProblem(50), isNull);
    expect(UndianRules.logoProblem(300 * 1024 + 1), 'Ukuran logo maksimal 300 KB.');
    expect(UndianRules.logoProblem(null), isNull);
    expect(UndianRules.nameProblem('  ', 'acara'), 'Nama acara wajib diisi.');
  });
}
