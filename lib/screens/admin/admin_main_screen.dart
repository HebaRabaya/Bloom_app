import 'package:flutter/material.dart';

import '../../widgets/bloom_nav_bar.dart';
import '../profile/profile_screen.dart';
import 'add_product_screen.dart';
import 'admin_home_screen.dart';
import 'categories_screen.dart';
import 'orders_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => AdminMainScreenState();

  static AdminMainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<AdminMainScreenState>();
  }
}

class AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  void goToTab(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          AdminHomeScreen(),
          AddProductScreen(),
          CategoriesScreen(),
          OrdersScreen(),
          ProfileScreen(isAdmin: true),
        ],
      ),
      bottomNavigationBar: BloomNavBar(
        currentIndex: _currentIndex,
        onChanged: goToTab,
        items: const [
          BloomNavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
          ),
          BloomNavItem(
            icon: Icons.add_box_outlined,
            activeIcon: Icons.add_box_rounded,
            label: 'Add',
          ),
          BloomNavItem(
            icon: Icons.category_outlined,
            activeIcon: Icons.category_rounded,
            label: 'Categories',
          ),
          BloomNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'Orders',
          ),
          BloomNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
