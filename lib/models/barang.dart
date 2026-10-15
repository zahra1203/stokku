class Barang {
  final String id;
  final String kodeBarang;
  final String namaBarang;
  final String kategori;
  final int jumlahStok;
  final double hargaBeli;
  final double hargaJual;

  Barang({
    String? id,
    required this.kodeBarang,
    required this.namaBarang,
    required this.kategori,
    this.jumlahStok = 0,
    this.hargaBeli = 0.0,
    this.hargaJual = 0.0,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        assert(jumlahStok >= 0, 'Jumlah stok tidak boleh negatif'),
        assert(hargaBeli >= 0, 'Harga beli tidak boleh negatif'),
        assert(hargaJual >= 0, 'Harga jual tidak boleh negatif');

  /// Menghitung nilai total aset dari barang ini (stok * harga beli).
  double get nilaiAset => jumlahStok * hargaBeli;

  /// Status ketersediaan stok:
  /// - 'Habis' jika stok == 0
  /// - 'Menipis' jika stok < 5
  /// - 'Aman' jika stok >= 5
  String get statusStok {
    if (jumlahStok == 0) {
      return 'Habis';
    } else if (jumlahStok < 5) {
      return 'Menipis';
    } else {
      return 'Aman';
    }
  }

  /// Membuat salinan objek [Barang] dengan properti baru.
  Barang copyWith({
    String? id,
    String? kodeBarang,
    String? namaBarang,
    String? kategori,
    int? jumlahStok,
    double? hargaBeli,
    double? hargaJual,
  }) {
    return Barang(
      id: id ?? this.id,
      kodeBarang: kodeBarang ?? this.kodeBarang,
      namaBarang: namaBarang ?? this.namaBarang,
      kategori: kategori ?? this.kategori,
      jumlahStok: jumlahStok ?? this.jumlahStok,
      hargaBeli: hargaBeli ?? this.hargaBeli,
      hargaJual: hargaJual ?? this.hargaJual,
    );
  }

  /// Mengonversi objek [Barang] ke bentuk [Map].
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kodeBarang': kodeBarang,
      'namaBarang': namaBarang,
      'kategori': kategori,
      'jumlahStok': jumlahStok,
      'hargaBeli': hargaBeli,
      'hargaJual': hargaJual,
    };
  }

  /// Membuat objek [Barang] dari sebuah [Map].
  factory Barang.fromMap(Map<String, dynamic> map) {
    return Barang(
      id: map['id'] as String?,
      kodeBarang: map['kodeBarang'] as String? ?? '',
      namaBarang: map['namaBarang'] as String? ?? '',
      kategori: map['kategori'] as String? ?? '',
      jumlahStok: (map['jumlahStok'] as num?)?.toInt() ?? 0,
      hargaBeli: (map['hargaBeli'] as num?)?.toDouble() ?? 0.0,
      hargaJual: (map['hargaJual'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'Barang(id: $id, kodeBarang: $kodeBarang, namaBarang: $namaBarang, '
        'kategori: $kategori, jumlahStok: $jumlahStok, '
        'hargaBeli: $hargaBeli, hargaJual: $hargaJual)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Barang && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
