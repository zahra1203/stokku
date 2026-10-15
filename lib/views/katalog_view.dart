import 'package:flutter/material.dart';
import '../controllers/inventory_controller.dart';
import '../models/barang.dart';
import '../widgets/kartu_barang.dart';
import '../widgets/dialog_form_barang.dart';

/// Halaman Katalog Barang yang menampilkan daftar barang, pencarian, filter, dan sorting.
class KatalogView extends StatefulWidget {
  final InventoryController controller;

  const KatalogView({
    super.key,
    required this.controller,
  });

  @override
  State<KatalogView> createState() => _KatalogViewState();
}

class _KatalogViewState extends State<KatalogView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _selectedSort = 'Nama A-Z';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _tambahBarang() async {
    final hasil = await DialogFormBarang.show(
      context,
      controller: widget.controller,
    );

    if (hasil != null && mounted) {
      widget.controller.tambahBarang(hasil);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barang "${hasil.namaBarang}" berhasil ditambahkan'),
        ),
      );
    }
  }

  void _editBarang(Barang barang) async {
    final hasil = await DialogFormBarang.show(
      context,
      controller: widget.controller,
      barang: barang,
    );

    if (hasil != null && mounted) {
      widget.controller.ubahBarang(barang.id, hasil);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barang "${hasil.namaBarang}" berhasil diperbarui'),
        ),
      );
    }
  }

  void _konfirmasiHapus(Barang barang) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Hapus Barang'),
          content: Text(
            'Apakah Anda yakin ingin menghapus barang "${barang.namaBarang}" (${barang.kodeBarang}) dari inventaris?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Theme.of(ctx).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (setuju == true && mounted) {
      widget.controller.hapusBarang(barang.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barang "${barang.namaBarang}" berhasil dihapus'),
        ),
      );
    }
  }

  List<Barang> _dapatkanDaftarBarang() {
    List<Barang> items = widget.controller.daftarBarang;

    // Filter Pencarian
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items.where((b) {
        return b.namaBarang.toLowerCase().contains(query) ||
            b.kodeBarang.toLowerCase().contains(query) ||
            b.kategori.toLowerCase().contains(query);
      }).toList();
    }

    // Filter Kategori / Status Stok
    if (_selectedFilter == 'Stok Menipis') {
      items = items.where((b) => b.jumlahStok > 0 && b.jumlahStok < 5).toList();
    } else if (_selectedFilter == 'Stok Habis') {
      items = items.where((b) => b.jumlahStok == 0).toList();
    } else if (_selectedFilter != 'Semua') {
      items = items
          .where((b) => b.kategori.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }

    // Pengurutan (Sorting)
    return widget.controller.urutkanBarang(items, _selectedSort);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final daftarTampil = _dapatkanDaftarBarang();
        final daftarKategori = widget.controller.getDaftarKategori();

        // Opsi filter: Semua, Stok Menipis, Stok Habis, + semua kategori unik
        final filterOptions = [
          'Semua',
          'Stok Menipis',
          'Stok Habis',
          ...daftarKategori,
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Katalog Barang'),
            centerTitle: false,
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SearchBar(
                  controller: _searchController,
                  hintText: 'Cari nama, kode, atau kategori...',
                  leading: const Icon(Icons.search),
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      ),
                  ],
                  onChanged: (_) => setState(() {}),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(
                    theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: filterOptions.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Baris Pilihan Urutan (Sorting) & Jumlah Item
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menampilkan ${daftarTampil.length} barang',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Urutkan: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedSort,
                          isDense: true,
                          underline: const SizedBox(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'Nama A-Z',
                              child: Text('Nama A-Z'),
                            ),
                            DropdownMenuItem(
                              value: 'Stok Terbanyak',
                              child: Text('Stok Terbanyak'),
                            ),
                            DropdownMenuItem(
                              value: 'Harga Jual Tertinggi',
                              child: Text('Harga Jual Tertinggi'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedSort = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Daftar Barang / Empty State
              Expanded(
                child: daftarTampil.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: theme.colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada barang ditemukan',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Coba sesuaikan kata kunci pencarian atau ganti filter yang dipilih.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: daftarTampil.length,
                        itemBuilder: (context, index) {
                          final item = daftarTampil[index];
                          return KartuBarang(
                            barang: item,
                            controller: widget.controller,
                            onTap: () => _editBarang(item),
                            onLongPress: () => _konfirmasiHapus(item),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _tambahBarang,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Barang'),
          ),
        );
      },
    );
  }
}
