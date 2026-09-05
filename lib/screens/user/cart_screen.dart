import 'package:flutter/material.dart';

import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';
import 'checkout_screen.dart';
import 'user_main_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService();

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      showBloomSnack(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> _confirmRemove(CartModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove item?'),
        content: Text(
          '${item.productName} will be removed from your cart.',
          style: AppText.sans(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(120, 44),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _run(() => _cartService.removeFromCart(item.productId));
  }

  /// The success screen pops with the tab the customer wants to land on.
  Future<void> _openCheckout() async {
    final result = await Navigator.push<String>(
      context,
      BloomPageRoute(builder: (_) => const CheckoutScreen()),
    );

    if (!mounted || result == null) return;

    UserMainScreen.of(context)?.goToTab(result == 'orders' ? 3 : 0);
  }

  @override
  Widget build(BuildContext context) {
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 14, padding, 6),
              child: Text('Your Cart', style: AppText.serif(size: 22)),
            ),
            Expanded(
              child: StreamBuilder<List<CartModel>>(
                stream: _cartService.getCart(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const BloomLoader();
                  }

                  final items = snapshot.data ?? const <CartModel>[];

                  if (items.isEmpty) {
                    return BloomEmptyState(
                      title: 'Your cart is empty',
                      message:
                          'Pick a bouquet you love and it will wait for you '
                          'right here.',
                      icon: Icons.shopping_bag_outlined,
                      actionLabel: 'Start shopping',
                      onAction: () => UserMainScreen.of(context)?.goToTab(0),
                    );
                  }

                  final subtotal = items.fold<double>(
                    0,
                    (sum, item) => sum + item.productPrice * item.quantity,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            padding,
                            12,
                            padding,
                            12,
                          ),
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return FadeSlideIn.staggered(
                              key: ValueKey(item.productId),
                              index: index,
                              child: _CartTile(
                                item: item,
                                onIncrease: () => _run(
                                  () => _cartService.increaseQuantity(item),
                                ),
                                onDecrease: () => _run(
                                  () => _cartService.decreaseQuantity(item),
                                ),
                                onRemove: () => _confirmRemove(item),
                              ),
                            );
                          },
                        ),
                      ),
                      _buildSummary(padding, subtotal, items.length),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(double padding, double subtotal, int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(padding, 20, padding, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.taupe.withValues(alpha: 0.18),
            blurRadius: 26,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal ($count items)', '\$${_money(subtotal)}'),
          const SizedBox(height: 9),
          _summaryRow('Delivery Fee', 'Free', valueColor: AppColors.success),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.line),
          ),
          Row(
            children: [
              Text(
                'Total',
                style: AppText.sans(size: 15, weight: FontWeight.w600),
              ),
              const Spacer(),
              BloomPrice(value: subtotal, size: 20),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _openCheckout,
            child: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(
          label,
          style: AppText.sans(size: 13, color: AppColors.muted),
        ),
        const Spacer(),
        Text(
          value,
          style: AppText.sans(
            size: 13,
            weight: FontWeight.w600,
            color: valueColor ?? AppColors.ink,
          ),
        ),
      ],
    );
  }

  static String _money(double value) {
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2);
  }
}

class _CartTile extends StatelessWidget {
  final CartModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final atMax = item.quantity >= item.availableQuantity;

    return BloomCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 72,
              height: 72,
              child: BloomImage(url: item.productImage),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(size: 13.5, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                BloomPrice(value: item.productPrice, size: 14),
                const SizedBox(height: 9),
                Row(
                  children: [
                    BloomQuantityStepper(
                      compact: true,
                      quantity: item.quantity,
                      onDecrease: onDecrease,
                      onIncrease: atMax ? null : onIncrease,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: onRemove,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
