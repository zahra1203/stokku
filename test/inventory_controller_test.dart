import 'package:flutter_test/flutter_test.dart';
import 'package:stokku/models/barang.dart';
import 'package:stokku/controllers/inventory_controller.dart';

void main() {
  group('Barang Model Tests', () {
    test('Inisialisasi dan getter statusStok serta nilaiAset', () {
      final itemHabis = Barang(
        kodeBarang: 'TST-001',
        namaBarang: 'Barang Habis',
        kategori: 'Umum',
        jumlahStok: 0,
        hargaBeli: 10000.0,
        hargaJual: 12000.0,
      );
      expect(itemHabis.statusStok, 'Habis');
      expect(itemHabis.nilaiAset, 0.0);
      expect(itemHabis.id.isNotEmpty, true);

      final itemMenipis = Barang(
        kodeBarang: 'TST-002',
        namaBarang: 'Barang Menipis',
        kategori: 'Umum',
        jumlahStok: 3,
        hargaBeli: 10000.0,
        hargaJual: 12000.0,
      );
      expect(itemMenipis.statusStok, 'Menipis');
      expect(itemMenipis.nilaiAset, 30000.0);

      final itemAman = Barang(
        kodeBarang: 'TST-003',
        namaBarang: 'Barang Aman',
        kategori: 'Umum',
        jumlahStok: 5,
        hargaBeli: 10000.0,
        hargaJual: 12000.0,
      );
      expect(itemAman.statusStok, 'Aman');
      expect(itemAman.nilaiAset, 50000.0);
    });

    test('copyWith bekerja dengan benar', () {
      final item = Barang(
        id: 'test-id',
        kodeBarang: 'TST-001',
        namaBarang: 'Nama Awal',
        kategori: 'Kategori A',
        jumlahStok: 10,
        hargaBeli: 5000.0,
        hargaJual: 7000.0,
      );

      final updated = item.copyWith(
        namaBarang: 'Nama Baru',
        jumlahStok: 15,
      );

      expect(updated.id, 'test-id');
      expect(updated.kodeBarang, 'TST-001');
      expect(updated.namaBarang, 'Nama Baru');
      expect(updated.kategori, 'Kategori A');
      expect(updated.jumlahStok, 15);
      expect(updated.hargaBeli, 5000.0);
      expect(updated.hargaJual, 7000.0);
    });
  });

  group('InventoryController Tests', () {
    late InventoryController controller;

    setUp(() {
      controller = InventoryController();
    });

    test('Data awal 5 produk UMKM terisi dengan benar', () {
      expect(controller.totalJenisBarang, 5);
      expect(controller.daftarBarang.length, 5);
      expect(controller.totalUnitStok, 25 + 12 + 4 + 0 + 18);
      expect(
        controller.totalNilaiAset,
        (25 * 65000.0) + (12 * 32000.0) + (4 * 14500.0) + (0 * 8500.0) + (18 * 5500.0),
      );
      expect(controller.barangMenipis.length, 1);
      expect(controller.barangMenipis.first.namaBarang, 'Gula Pasir 1kg');
      expect(controller.barangHabis.length, 1);
      expect(controller.barangHabis.first.namaBarang, 'Sabun Cuci Piring');
    });

    test('tambahBarang menambah barang dan memicu notifikasi', () {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      final baru = Barang(
        kodeBarang: 'BRG-006',
        namaBarang: 'Kopi Bubuk 250g',
        kategori: 'Minuman',
        jumlahStok: 10,
        hargaBeli: 12000.0,
        hargaJual: 15000.0,
      );

      controller.tambahBarang(baru);

      expect(controller.totalJenisBarang, 6);
      expect(notifyCount, 1);
      expect(controller.isKodeBarangExist('BRG-006'), true);
    });

    test('ubahBarang memperbarui barang berdasarkan ID', () {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      final barangTarget = controller.daftarBarang.first;
      final diubah = barangTarget.copyWith(namaBarang: 'Beras Super 5kg');

      controller.ubahBarang(barangTarget.id, diubah);

      expect(controller.daftarBarang.first.namaBarang, 'Beras Super 5kg');
      expect(notifyCount, 1);
    });

    test('hapusBarang menghapus barang berdasarkan ID', () {
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      final idDihapus = controller.daftarBarang.first.id;
      controller.hapusBarang(idDihapus);

      expect(controller.totalJenisBarang, 4);
      expect(notifyCount, 1);
    });

    test('tambahStok dan kurangiStok bekerja sesuai batas', () {
      final barang4 = controller.daftarBarang.firstWhere((b) => b.id == '4');
      expect(barang4.jumlahStok, 0);

      // kurangiStok tidak boleh membuat stok negatif
      controller.kurangiStok('4');
      expect(controller.daftarBarang.firstWhere((b) => b.id == '4').jumlahStok, 0);

      // tambahStok
      controller.tambahStok('4');
      expect(controller.daftarBarang.firstWhere((b) => b.id == '4').jumlahStok, 1);

      // kurangiStok kembali
      controller.kurangiStok('4');
      expect(controller.daftarBarang.firstWhere((b) => b.id == '4').jumlahStok, 0);
    });

    test('isKodeBarangExist mengecek keunikan kode dan excludeId', () {
      expect(controller.isKodeBarangExist('BRG-001'), true);
      expect(controller.isKodeBarangExist('brg-001'), true);
      expect(controller.isKodeBarangExist('BRG-001', excludeId: '1'), false);
      expect(controller.isKodeBarangExist('BRG-999'), false);
    });

    test('cariBarang mencari berdasarkan nama, kode, dan kategori secara case-insensitive', () {
      final cariNama = controller.cariBarang('beras');
      expect(cariNama.length, 1);
      expect(cariNama.first.kodeBarang, 'BRG-001');

      final cariKode = controller.cariBarang('002');
      expect(cariKode.length, 1);
      expect(cariKode.first.namaBarang, 'Minyak Goreng 2L');

      final cariKategori = controller.cariBarang('sembako');
      expect(cariKategori.length, 3);
    });

    test('filterBarang menyaring berdasarkan status dan kategori', () {
      final menipis = controller.filterBarang(filter: 'Menipis');
      expect(menipis.length, 1);
      expect(menipis.first.namaBarang, 'Gula Pasir 1kg');

      final habis = controller.filterBarang(filter: 'Habis');
      expect(habis.length, 1);
      expect(habis.first.namaBarang, 'Sabun Cuci Piring');

      final sembako = controller.filterBarang(kategori: 'Sembako');
      expect(sembako.length, 3);

      final sembakoMenipis = controller.filterBarang(filter: 'Menipis', kategori: 'Sembako');
      expect(sembakoMenipis.length, 1);
      expect(sembakoMenipis.first.namaBarang, 'Gula Pasir 1kg');
    });

    test('urutkanBarang mengurutkan daftar barang', () {
      final list = controller.daftarBarang;

      final sortNama = controller.urutkanBarang(list, 'Nama A-Z');
      expect(sortNama.first.namaBarang, 'Beras Premium 5kg');

      final sortStok = controller.urutkanBarang(list, 'Stok Terbanyak');
      expect(sortStok.first.jumlahStok, 25);
      expect(sortStok.last.jumlahStok, 0);

      final sortHarga = controller.urutkanBarang(list, 'Harga Jual Tertinggi');
      expect(sortHarga.first.hargaJual, 72000.0);
      expect(sortHarga.last.hargaJual, 7000.0);
    });

    test('getDaftarKategori mengembalikan daftar kategori unik yang berurutan', () {
      final kategori = controller.getDaftarKategori();
      expect(kategori.contains('Sembako'), true);
      expect(kategori.contains('Kebersihan'), true);
      expect(kategori.contains('Minuman'), true);
      expect(kategori.length, 3);
    });
  });
}
