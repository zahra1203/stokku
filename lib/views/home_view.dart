import 'package:flutter/material.dart';
import '../controllers/inventory_controller.dart';
import 'dashboard_view.dart';
import 'katalog_view.dart';

/// Halaman utama dengan navigasi tab IndexedStack untuk mempertahankan status state antar tab.
class HomeView extends StatefulWidget {
  final InventoryController controller;

  const HomeView({
    super.key,
    required this.controller,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardView(controller: widget.controller),
          KatalogView(controller: widget.controller),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Katalog',
          ),
        ],
      ),
    );
  }
}
