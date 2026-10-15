import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barang.dart';
import '../controllers/inventory_controller.dart';

/// Widget kartu untuk menampilkan informasi barang pada katalog.
class KartuBarang extends StatelessWidget {
  final Barang barang;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onTambahStok;
  final VoidCallback? onKurangiStok;
  final InventoryController? controller;

  const KartuBarang({
    super.key,
    required this.barang,
    this.onTap,
    this.onLongPress,
    this.onTambahStok,
    this.onKurangiStok,
    this.controller,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aman':
        return Colors.green;
      case 'Menipis':
        return Colors.orange;
      case 'Habis':
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final statusColor = _getStatusColor(barang.statusStok);

    final handleTambah = onTambahStok ??
        (controller != null ? () => controller!.tambahStok(barang.id) : null);
    final handleKurangi = onKurangiStok ??
        (controller != null ? () => controller!.kurangiStok(barang.id) : null);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris Atas: Nama Barang dan Badge Status Stok
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barang.namaBarang,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${barang.kodeBarang} • ${barang.kategori}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badge Status Stok
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          barang.statusStok,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Baris Bawah: Harga Jual dan Pengatur Jumlah Stok (+/-)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga Jual',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormat.format(barang.hargaJual),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  // Tombol Penyesuaian Cepat Stok (+/-)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.remove),
                          tooltip: 'Kurangi Stok',
                          onPressed: barang.jumlahStok > 0 ? handleKurangi : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            '${barang.jumlahStok}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          iconSize: 20,
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.add),
                          tooltip: 'Tambah Stok',
                          onPressed: handleTambah,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
