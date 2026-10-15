import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/barang.dart';
import '../controllers/inventory_controller.dart';

/// Dialog form untuk menambah atau memperbarui data barang.
class DialogFormBarang extends StatefulWidget {
  final InventoryController controller;
  final Barang? barang;

  const DialogFormBarang({
    super.key,
    required this.controller,
    this.barang,
  });

  /// Helper untuk menampilkan dialog secara praktis.
  static Future<Barang?> show(
    BuildContext context, {
    required InventoryController controller,
    Barang? barang,
  }) {
    return showDialog<Barang>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DialogFormBarang(
        controller: controller,
        barang: barang,
      ),
    );
  }

  @override
  State<DialogFormBarang> createState() => _DialogFormBarangState();
}

class _DialogFormBarangState extends State<DialogFormBarang> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _kodeController;
  late final TextEditingController _namaController;
  late final TextEditingController _kategoriController;
  late final TextEditingController _stokController;
  late final TextEditingController _hargaBeliController;
  late final TextEditingController _hargaJualController;

  bool get _isEditing => widget.barang != null;

  @override
  void initState() {
    super.initState();
    final barang = widget.barang;
    _kodeController = TextEditingController(text: barang?.kodeBarang ?? '');
    _namaController = TextEditingController(text: barang?.namaBarang ?? '');
    _kategoriController = TextEditingController(text: barang?.kategori ?? '');
    _stokController = TextEditingController(
      text: barang != null ? barang.jumlahStok.toString() : '0',
    );
    _hargaBeliController = TextEditingController(
      text: barang != null ? _formatAngka(barang.hargaBeli) : '',
    );
    _hargaJualController = TextEditingController(
      text: barang != null ? _formatAngka(barang.hargaJual) : '',
    );
  }

  String _formatAngka(double val) {
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toString();
  }

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    _kategoriController.dispose();
    _stokController.dispose();
    _hargaBeliController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final stok = int.parse(_stokController.text.trim());
    final hargaBeli = double.parse(_hargaBeliController.text.trim());
    final hargaJual = double.parse(_hargaJualController.text.trim());

    final hasilBarang = Barang(
      id: widget.barang?.id,
      kodeBarang: _kodeController.text.trim().toUpperCase(),
      namaBarang: _namaController.text.trim(),
      kategori: _kategoriController.text.trim(),
      jumlahStok: stok,
      hargaBeli: hargaBeli,
      hargaJual: hargaJual,
    );

    Navigator.of(context).pop(hasilBarang);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Ubah Data Barang' : 'Tambah Barang Baru'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Kode Barang
                TextFormField(
                  controller: _kodeController,
                  decoration: const InputDecoration(
                    labelText: 'Kode Barang',
                    hintText: 'Contoh: BRG-001',
                    prefixIcon: Icon(Icons.qr_code),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    final cleanValue = value?.trim() ?? '';
                    if (cleanValue.isEmpty) {
                      return 'Kode barang wajib diisi';
                    }
                    if (widget.controller.isKodeBarangExist(
                      cleanValue,
                      excludeId: widget.barang?.id,
                    )) {
                      return 'Kode barang sudah digunakan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nama Barang
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Barang',
                    hintText: 'Contoh: Beras Premium 5kg',
                    prefixIcon: Icon(Icons.shopping_bag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    final cleanValue = value?.trim() ?? '';
                    if (cleanValue.isEmpty) {
                      return 'Nama barang wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategori
                TextFormField(
                  controller: _kategoriController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    hintText: 'Contoh: Sembako, Minuman, Alat Tulis',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    final cleanValue = value?.trim() ?? '';
                    if (cleanValue.isEmpty) {
                      return 'Kategori wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Jumlah Stok
                TextFormField(
                  controller: _stokController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah Stok',
                    hintText: '0',
                    prefixIcon: Icon(Icons.numbers_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    final cleanValue = value?.trim() ?? '';
                    if (cleanValue.isEmpty) {
                      return 'Jumlah stok wajib diisi';
                    }
                    final stok = int.tryParse(cleanValue);
                    if (stok == null) {
                      return 'Jumlah stok harus berupa bilangan bulat';
                    }
                    if (stok < 0) {
                      return 'Jumlah stok tidak boleh negatif';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Harga Beli
                TextFormField(
                  controller: _hargaBeliController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Beli (Modal)',
                    hintText: 'Contoh: 15000',
                    prefixIcon: Icon(Icons.price_change_outlined),
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    final cleanValue = value?.trim() ?? '';
                    if (cleanValue.isEmpty) {
                      return 'Harga beli wajib diisi';
                    }
                    final harga = double.tryParse(cleanValue);
                    if (harga == null) {
                      return 'Harga beli harus berupa angka valid';
                    }
                    if (harga < 0) {
                      return 'Harga beli tidak boleh negatif';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Harga Jual
                TextFormField(
                  controller: _hargaJualController,
                  decoration: const InputDecoration(
                    labelText: 'Harga Jual',
                    hintText: 'Contoh: 18000',
                    prefixIcon: Icon(Icons.sell_outlined),
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    final cleanValue = value?.trim() ?? '';
                    if (cleanValue.isEmpty) {
                      return 'Harga jual wajib diisi';
                    }
                    final harga = double.tryParse(cleanValue);
                    if (harga == null) {
                      return 'Harga jual harus berupa angka valid';
                    }
                    if (harga < 0) {
                      return 'Harga jual tidak boleh negatif';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _simpan,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
