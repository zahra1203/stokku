import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/inventory_controller.dart';
import '../models/barang.dart';
import '../widgets/kartu_ringkasan.dart';
import '../widgets/dialog_form_barang.dart';

/// Halaman Dashboard yang menampilkan ringkasan data inventaris dan peringatan stok.
class DashboardView extends StatelessWidget {
  final InventoryController controller;

  const DashboardView({
    super.key,
    required this.controller,
  });

  void _onBarangTap(BuildContext context, Barang barang) async {
    final updated = await DialogFormBarang.show(
      context,
      controller: controller,
      barang: barang,
    );
    if (updated != null && context.mounted) {
      controller.ubahBarang(barang.id, updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Barang "${updated.namaBarang}" berhasil diperbarui'),
        ),
      );
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

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final menipis = controller.barangMenipis;
        final habis = controller.barangHabis;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard Inventaris'),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian Kartu Ringkasan
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 700) {
                      return Row(
                        children: [
                          Expanded(
                            child: KartuRingkasan(
                              title: 'Total Jenis Barang',
                              value: '${controller.totalJenisBarang} Jenis',
                              icon: Icons.category,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: KartuRingkasan(
                              title: 'Total Unit Stok',
                              value: '${controller.totalUnitStok} Unit',
                              icon: Icons.inventory_2,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: KartuRingkasan(
                              title: 'Total Nilai Aset',
                              value: currencyFormat.format(controller.totalNilaiAset),
                              icon: Icons.account_balance_wallet,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: KartuRingkasan(
                                  title: 'Total Jenis Barang',
                                  value: '${controller.totalJenisBarang} Jenis',
                                  icon: Icons.category,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: KartuRingkasan(
                                  title: 'Total Unit Stok',
                                  value: '${controller.totalUnitStok} Unit',
                                  icon: Icons.inventory_2,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: KartuRingkasan(
                              title: 'Total Nilai Aset',
                              value: currencyFormat.format(controller.totalNilaiAset),
                              icon: Icons.account_balance_wallet,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Judul Bagian Peringatan Stok
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Peringatan Stok',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sub-bagian: Stok Menipis (< 5)
                Text(
                  'Stok Menipis (< 5)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                if (menipis.isEmpty)
                  _buildEmptyWarningCard(
                    context,
                    'Tidak ada barang dengan stok menipis',
                    Icons.check_circle_outline,
                    Colors.green,
                  )
                else
                  ...menipis.map(
                    (barang) => _buildWarningItem(
                      context,
                      barang,
                      badgeColor: Colors.orange,
                      badgeText: '${barang.jumlahStok} unit tersisa',
                    ),
                  ),

                const SizedBox(height: 20),

                // Sub-bagian: Stok Habis
                Text(
                  'Stok Habis',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                if (habis.isEmpty)
                  _buildEmptyWarningCard(
                    context,
                    'Tidak ada barang dengan stok habis',
                    Icons.check_circle_outline,
                    Colors.green,
                  )
                else
                  ...habis.map(
                    (barang) => _buildWarningItem(
                      context,
                      barang,
                      badgeColor: theme.colorScheme.error,
                      badgeText: 'Habis (0 unit)',
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWarningCard(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningItem(
    BuildContext context,
    Barang barang, {
    required Color badgeColor,
    required String badgeText,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () => _onBarangTap(context, barang),
        title: Text(
          barang.namaBarang,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${barang.kodeBarang} • ${barang.kategori}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
          ),
          child: Text(
            badgeText,
            style: theme.textTheme.labelMedium?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
