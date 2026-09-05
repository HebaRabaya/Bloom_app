import 'package:flutter/material.dart';

import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import '../../widgets/bloom_nav_bar.dart';
import '../profile/profile_screen.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';
import 'search_screen.dart';
import 'user_home_screen.dart';

/// Shell for the customer experience. Tabs keep their state via [IndexedStack],
/// and the cart tab shows a live badge from Firestore.
class UserMainScreen extends StatefulWidget {
  final int initialIndex;

  const UserMainScreen({super.key, this.initialIndex = 0});

  @override
  State<UserMainScreen> createState() => UserMainScreenState();

  /// Lets child screens jump between tabs (for example "Shop now" from an
  /// empty cart).
  static UserMainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<UserMainScreenState>();
  }
}

class UserMainScreenState extends State<UserMainScreen> {
  final CartService _cartService = CartService();

  late int _currentIndex = widget.initialIndex;

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
          UserHomeScreen(),
          SearchScreen(),
          CartScreen(),
          MyOrdersScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: StreamBuilder<List<CartModel>>(
        stream: _cartService.getCart(),
        builder: (context, snapshot) {
          var count = 0;
          for (final item in snapshot.data ?? const <CartModel>[]) {
            count += item.quantity;
          }

          return BloomNavBar(
            currentIndex: _currentIndex,
            onChanged: goToTab,
            badges: {2: count},
            items: const [
              BloomNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
              ),
              BloomNavItem(
                icon: Icons.search_rounded,
                activeIcon: Icons.search_rounded,
                label: 'Search',
              ),
              BloomNavItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: 'Cart',
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
          );
        },
      ),
    );
  }
}
