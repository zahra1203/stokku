import 'package:flutter_test/flutter_test.dart';
import 'package:stokku/main.dart';

void main() {
  testWidgets('StokKu smoke test', (WidgetTester tester) async {
    // Membangun aplikasi StokKu
    await tester.pumpWidget(const StokKuApp());
    await tester.pumpAndSettle();

    // Memverifikasi bahwa judul halaman Dashboard tampil
    expect(find.text('Dashboard Inventaris'), findsOneWidget);
    expect(find.text('Total Jenis Barang'), findsOneWidget);
    expect(find.text('Total Unit Stok'), findsOneWidget);
  });
}
