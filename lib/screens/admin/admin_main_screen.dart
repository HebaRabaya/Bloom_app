import 'package:flutter/material.dart';

import '../ profile/profile_screen.dart';
import 'add_product_screen.dart';
import 'admin_home_screen.dart';
import 'categories_screen.dart';
import 'orders_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() =>
      _AdminMainScreenState();
}

class _AdminMainScreenState
    extends State<AdminMainScreen> {
  int _currentIndex = 0;

  // ============================================================
  // Admin Screens
  // ============================================================

  final List<Widget> _screens = const [
    AdminHomeScreen(),
    AddProductScreen(),
    CategoriesScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // الشاشة الحالية
      body: _screens[_currentIndex],

      // ========================================================
      // Bottom Navigation
      // ========================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,

        indicatorColor:
        const Color(0xFFE8D1D4),

        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon:
            Icon(Icons.home_outlined),
            selectedIcon:
            Icon(Icons.home),
            label: 'Home',
          ),

          NavigationDestination(
            icon:
            Icon(Icons.add_box_outlined),
            selectedIcon:
            Icon(Icons.add_box),
            label: 'Add',
          ),

          NavigationDestination(
            icon:
            Icon(Icons.category_outlined),
            selectedIcon:
            Icon(Icons.category),
            label: 'Categories',
          ),

          NavigationDestination(
            icon:
            Icon(Icons.receipt_long_outlined),
            selectedIcon:
            Icon(Icons.receipt_long),
            label: 'Orders',
          ),

          NavigationDestination(
            icon:
            Icon(Icons.person_outline),
            selectedIcon:
            Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}