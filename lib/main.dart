import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'controllers/inventory_controller.dart';
import 'views/home_view.dart';

void main() {
  // Memastikan binding Flutter terinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'id_ID';
  runApp(const StokKuApp());
}

/// Aplikasi utama StokKu - Manajemen Inventaris UMKM
class StokKuApp extends StatefulWidget {
  const StokKuApp({super.key});

  @override
  State<StokKuApp> createState() => _StokKuAppState();
}

class _StokKuAppState extends State<StokKuApp> {
  late final InventoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = InventoryController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StokKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: HomeView(controller: _controller),
    );
  }
}
