import 'package:flutter/material.dart';

import '../ profile/profile_screen.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'my_orders_screen.dart';
import 'user_home_screen.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({
    super.key,
  });

  @override
  State<UserMainScreen> createState() =>
      _UserMainScreenState();
}

class _UserMainScreenState
    extends State<UserMainScreen> {

  // ============================================================
  // Current Navigation Index
  // ============================================================

  int _currentIndex = 0;

  // ============================================================
  // User Screens
  // ============================================================

  final List<Widget> _screens = [
    UserHomeScreen(),
    FavoritesScreen(),
    CartScreen(),
    MyOrdersScreen(),
    ProfileScreen(),
  ];

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],

      // ========================================================
      // Bottom Navigation
      // ========================================================

      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        _currentIndex,

        indicatorColor:
        const Color(0xFFE8D1D4),

        onDestinationSelected:
            (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        destinations: const [
          // ====================================================
          // Home
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          // ====================================================
          // Favorites
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons.favorite_border,
            ),
            selectedIcon: Icon(
              Icons.favorite,
            ),
            label: 'Favorites',
          ),

          // ====================================================
          // Cart
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons.shopping_bag_outlined,
            ),
            selectedIcon: Icon(
              Icons.shopping_bag,
            ),
            label: 'Cart',
          ),

          // ====================================================
          // My Orders
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            selectedIcon: Icon(
              Icons.receipt_long,
            ),
            label: 'My Orders',
          ),

          // ====================================================
          // Profile
          // ====================================================

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
            ),
            selectedIcon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}