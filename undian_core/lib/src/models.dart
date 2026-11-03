/// Jenis hadiah.
enum PrizeKind { doorprize, grandprize }

/// Status seorang pemenang.
enum WinnerStatus {
  /// Baru terundi, menunggu penyerahan.
  sah,

  /// Hadiah sudah diserahkan langsung.
  diserahkan,

  /// Hadiah dikirim/ditransfer (mis. peserta daerah yang tidak hadir).
  ditransfer,

  /// Pemenang tidak hadir/batal; unit hadiah kembali ke stok untuk diundi ulang.
  hangus;

  /// Apakah status ini memakai satu unit stok hadiah.
  bool get usesStock => this != WinnerStatus.hangus;
}

class Participant {
  const Participant({
    required this.id,
    required this.nik,
    required this.name,
    this.area = '',
    this.department = '',
    this.employmentStatus = '',
    this.groups = const {},
    this.points = 1,
  });

  final int id;

  /// Nomor induk karyawan, sekaligus nomor undian.
  final String nik;
  final String name;
  final String area;
  final String department;
  final String employmentStatus;

  /// Grup yang diikuti, mis. "Doorprize Bogor". Dicocokkan persis, bukan sebagian teks.
  final Set<String> groups;

  /// Bobot peluang. Poin N sama dengan N tiket undian (seperti "Generate Poin" di aplikasi lama).
  final int points;
}

class Prize {
  const Prize({
    required this.id,
    required this.name,
    required this.kind,
    required this.quantity,
    this.eligibleGroups = const {},
    this.openToAll = false,
  });

  final int id;
  final String name;
  final PrizeKind kind;

  /// Jumlah unit hadiah.
  final int quantity;

  /// Peserta berhak jika menjadi anggota salah satu grup ini.
  final Set<String> eligibleGroups;

  /// Jika true, semua peserta berhak tanpa melihat grup. Sengaja dibuat eksplisit:
  /// daftar grup yang kosong berarti tidak ada yang berhak, bukan semua orang.
  final bool openToAll;
}

class Winner {
  const Winner({required this.participantId, required this.prizeId, this.status = WinnerStatus.sah});

  final int participantId;
  final int prizeId;
  final WinnerStatus status;

  Winner copyWith({WinnerStatus? status}) =>
      Winner(participantId: participantId, prizeId: prizeId, status: status ?? this.status);
}
