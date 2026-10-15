import 'package:flutter/foundation.dart';
import '../models/barang.dart';

/// Controller untuk mengelola data inventaris stok barang aplikasi StokKu.
/// Menggunakan [ChangeNotifier] untuk manajemen state.
class InventoryController extends ChangeNotifier {
  final List<Barang> _daftarBarang = [];

  InventoryController({List<Barang>? initialData}) {
    if (initialData != null) {
      _daftarBarang.addAll(initialData);
    } else {
      _initSampleData();
    }
  }

  /// Inisialisasi 5 contoh data produk UMKM Indonesia dengan harga realistis.
  void _initSampleData() {
    _daftarBarang.addAll([
      Barang(
        id: '1',
        kodeBarang: 'BRG-001',
        namaBarang: 'Beras Premium 5kg',
        kategori: 'Sembako',
        jumlahStok: 25,
        hargaBeli: 65000.0,
        hargaJual: 72000.0,
      ),
      Barang(
        id: '2',
        kodeBarang: 'BRG-002',
        namaBarang: 'Minyak Goreng 2L',
        kategori: 'Sembako',
        jumlahStok: 12,
        hargaBeli: 32000.0,
        hargaJual: 36000.0,
      ),
      Barang(
        id: '3',
        kodeBarang: 'BRG-003',
        namaBarang: 'Gula Pasir 1kg',
        kategori: 'Sembako',
        jumlahStok: 4, // Status: Menipis (< 5 dan > 0)
        hargaBeli: 14500.0,
        hargaJual: 17000.0,
      ),
      Barang(
        id: '4',
        kodeBarang: 'BRG-004',
        namaBarang: 'Sabun Cuci Piring',
        kategori: 'Kebersihan',
        jumlahStok: 0, // Status: Habis (== 0)
        hargaBeli: 8500.0,
        hargaJual: 10500.0,
      ),
      Barang(
        id: '5',
        kodeBarang: 'BRG-005',
        namaBarang: 'Teh Celup Kotak',
        kategori: 'Minuman',
        jumlahStok: 18,
        hargaBeli: 5500.0,
        hargaJual: 7000.0,
      ),
    ]);
  }

  /// Mengembalikan daftar barang yang tidak dapat dimodifikasi secara langsung.
  List<Barang> get daftarBarang => List.unmodifiable(_daftarBarang);

  /// Jumlah total jenis barang yang terdaftar.
  int get totalJenisBarang => _daftarBarang.length;

  /// Jumlah total unit stok dari seluruh barang.
  int get totalUnitStok =>
      _daftarBarang.fold<int>(0, (sum, item) => sum + item.jumlahStok);

  /// Total nilai aset modal inventaris (jumlah stok * harga beli).
  double get totalNilaiAset =>
      _daftarBarang.fold<double>(0.0, (sum, item) => sum + item.nilaiAset);

  /// Daftar barang dengan stok menipis (jumlahStok > 0 dan jumlahStok < 5).
  List<Barang> get barangMenipis =>
      _daftarBarang.where((item) => item.jumlahStok > 0 && item.jumlahStok < 5).toList();

  /// Daftar barang dengan stok habis (jumlahStok == 0).
  List<Barang> get barangHabis =>
      _daftarBarang.where((item) => item.jumlahStok == 0).toList();

  /// Menambahkan barang baru ke dalam daftar.
  void tambahBarang(Barang barang) {
    _daftarBarang.add(barang);
    notifyListeners();
  }

  /// Memperbarui data barang berdasarkan [id].
  void ubahBarang(String id, Barang barangBaru) {
    final index = _daftarBarang.indexWhere((item) => item.id == id);
    if (index != -1) {
      _daftarBarang[index] = barangBaru;
      notifyListeners();
    }
  }

  /// Menghapus barang dari daftar berdasarkan [id].
  void hapusBarang(String id) {
    _daftarBarang.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  /// Menambah stok barang sebanyak 1 unit.
  void tambahStok(String id) {
    final index = _daftarBarang.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _daftarBarang[index];
      _daftarBarang[index] = item.copyWith(jumlahStok: item.jumlahStok + 1);
      notifyListeners();
    }
  }

  /// Mengurangi stok barang sebanyak 1 unit (minimal 0).
  void kurangiStok(String id) {
    final index = _daftarBarang.indexWhere((item) => item.id == id);
    if (index != -1) {
      final item = _daftarBarang[index];
      if (item.jumlahStok > 0) {
        _daftarBarang[index] = item.copyWith(jumlahStok: item.jumlahStok - 1);
        notifyListeners();
      }
    }
  }

  /// Memeriksa apakah kode barang sudah ada di dalam daftar.
  /// [excludeId] digunakan saat mengedit barang agar tidak membandingkan dengan barang itu sendiri.
  bool isKodeBarangExist(String kode, {String? excludeId}) {
    final normalizedKode = kode.trim().toLowerCase();
    return _daftarBarang.any((barang) {
      if (excludeId != null && barang.id == excludeId) {
        return false;
      }
      return barang.kodeBarang.trim().toLowerCase() == normalizedKode;
    });
  }

  /// Mencari barang berdasarkan nama, kode, atau kategori (case-insensitive).
  List<Barang> cariBarang(String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return List.unmodifiable(_daftarBarang);
    }
    return _daftarBarang.where((barang) {
      return barang.namaBarang.toLowerCase().contains(cleanQuery) ||
          barang.kodeBarang.toLowerCase().contains(cleanQuery) ||
          barang.kategori.toLowerCase().contains(cleanQuery);
    }).toList();
  }

  /// Menyaring daftar barang berdasarkan status ('Semua', 'Menipis', 'Habis') atau [kategori].
  List<Barang> filterBarang({String? filter, String? kategori}) {
    List<Barang> hasil = List.from(_daftarBarang);

    // Filter berdasarkan kategori spesifik
    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      hasil = hasil
          .where((b) => b.kategori.toLowerCase() == kategori.toLowerCase())
          .toList();
    }

    // Filter berdasarkan status ketersediaan atau kata kunci filter
    if (filter != null && filter.isNotEmpty && filter != 'Semua') {
      switch (filter) {
        case 'Menipis':
          hasil = hasil.where((b) => b.jumlahStok > 0 && b.jumlahStok < 5).toList();
          break;
        case 'Habis':
          hasil = hasil.where((b) => b.jumlahStok == 0).toList();
          break;
        case 'Aman':
          hasil = hasil.where((b) => b.jumlahStok >= 5).toList();
          break;
        default:
          // Jika nilai filter merujuk pada kategori
          if (_daftarBarang.any((b) => b.kategori.toLowerCase() == filter.toLowerCase())) {
            hasil = hasil
                .where((b) => b.kategori.toLowerCase() == filter.toLowerCase())
                .toList();
          }
          break;
      }
    }

    return hasil;
  }

  /// Mengurutkan daftar barang berdasarkan kriteria:
  /// - 'Nama A-Z'
  /// - 'Nama Z-A'
  /// - 'Stok Terbanyak'
  /// - 'Stok Tersedikit'
  /// - 'Harga Jual Tertinggi'
  /// - 'Harga Jual Terendah'
  List<Barang> urutkanBarang(List<Barang> list, String sortBy) {
    final sortedList = List<Barang>.from(list);
    switch (sortBy) {
      case 'Nama A-Z':
        sortedList.sort((a, b) =>
            a.namaBarang.toLowerCase().compareTo(b.namaBarang.toLowerCase()));
        break;
      case 'Nama Z-A':
        sortedList.sort((a, b) =>
            b.namaBarang.toLowerCase().compareTo(a.namaBarang.toLowerCase()));
        break;
      case 'Stok Terbanyak':
        sortedList.sort((a, b) => b.jumlahStok.compareTo(a.jumlahStok));
        break;
      case 'Stok Tersedikit':
        sortedList.sort((a, b) => a.jumlahStok.compareTo(b.jumlahStok));
        break;
      case 'Harga Jual Tertinggi':
        sortedList.sort((a, b) => b.hargaJual.compareTo(a.hargaJual));
        break;
      case 'Harga Jual Terendah':
        sortedList.sort((a, b) => a.hargaJual.compareTo(b.hargaJual));
        break;
      default:
        break;
    }
    return sortedList;
  }

  /// Mengambil daftar semua kategori unik dari barang yang ada.
  List<String> getDaftarKategori() {
    final kategoriSet = <String>{};
    for (final barang in _daftarBarang) {
      final trimmed = barang.kategori.trim();
      if (trimmed.isNotEmpty) {
        kategoriSet.add(trimmed);
      }
    }
    return kategoriSet.toList()..sort();
  }

  /// Mencari satu barang berdasarkan [id].
  Barang? getBarangById(String id) {
    try {
      return _daftarBarang.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Mengatur ulang daftar barang ke data contoh awal.
  void muatUlangDataContoh() {
    _daftarBarang.clear();
    _initSampleData();
    notifyListeners();
  }
}
