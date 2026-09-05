import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/cart_model.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  final _orderService = OrderService();
  final _profileService = ProfileService();
  final _cartService = CartService();

  bool _isLoadingAddress = true;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // ============================================================
  // Saved delivery address
  // ============================================================

  Future<void> _loadAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoadingAddress = false);
      return;
    }

    try {
      final document = await _profileService.getProfile(user.uid);
      _addressController.text =
          document.data()?['address']?.toString() ?? '';
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to load your saved address.');
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  // ============================================================
  // Place order
  // ============================================================

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();

    final address = _addressController.text.trim();

    if (address.isEmpty) {
      showBloomSnack(
        context,
        'Please enter your delivery address.',
        isError: true,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showBloomSnack(context, 'No logged-in user found.', isError: true);
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      await _profileService.saveAddress(uid: user.uid, address: address);
      final orderId = await _orderService.checkout(address: address);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        BloomPageRoute(
          builder: (_) => OrderSuccessScreen(orderId: orderId),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showBloomSnack(context, _checkoutError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  String _checkoutError(Object error) {
    final message = error.toString();

    if (message.contains('Not enough stock')) {
      return message.replaceFirst('Exception: ', '');
    }
    if (message.contains('cart is empty')) {
      return 'Your cart is empty.';
    }
    if (message.contains('address')) {
      return 'Please enter your delivery address.';
    }
    return 'Unable to complete checkout. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BloomCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 62,
        title: const Text('Checkout'),
      ),
      body: _isLoadingAddress
          ? const BloomLoader()
          : StreamBuilder<List<CartModel>>(
              stream: _cartService.getCart(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <CartModel>[];

                final total = items.fold<double>(
                  0,
                  (sum, item) => sum + item.productPrice * item.quantity,
                );

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        children: [
                          FadeSlideIn(child: _buildAddressSection()),
                          const SizedBox(height: 22),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 90),
                            child: _buildPaymentSection(),
                          ),
                          const SizedBox(height: 22),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 150),
                            child: _buildSummarySection(items, total),
                          ),
                        ],
                      ),
                    ),
                    _buildFooter(padding, total, items.isEmpty),
                  ],
                );
              },
            ),
    );
  }

  // ============================================================
  // Sections
  // ============================================================

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Delivery Address', Icons.location_on_outlined),
        const SizedBox(height: 12),
        BloomCard(
          padding: const EdgeInsets.all(6),
          child: TextField(
            controller: _addressController,
            maxLines: 3,
            style: AppText.sans(size: 13.5, height: 1.5),
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.all(14),
              hintText:
                  'Street, building, apartment…\nCity, area and landmark',
              hintStyle: AppText.sans(
                size: 13,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Payment Method', Icons.credit_card_outlined),
        const SizedBox(height: 12),
        BloomCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.forestSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 20,
                  color: AppColors.forest,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash on Delivery',
                      style: AppText.sans(size: 13.5, weight: FontWeight.w600),
                    ),
                    Text(
                      'Pay the courier when your flowers arrive.',
                      style: AppText.sans(size: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.forest,
                size: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(List<CartModel> items, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Order Summary', Icons.receipt_long_outlined),
        const SizedBox(height: 12),
        BloomCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Your cart is empty.',
                    style: AppText.sans(size: 13, color: AppColors.muted),
                  ),
                ),
              for (final item in items) ...[
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: BloomImage(url: item.productImage),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sans(
                              size: 13,
                              weight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Qty ${item.quantity}',
                            style: AppText.sans(
                              size: 11.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    BloomPrice(
                      value: item.productPrice * item.quantity,
                      size: 13.5,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: AppColors.line),
                ),
              ],
              _row('Items total', '\$${_money(total)}'),
              const SizedBox(height: 8),
              _row('Delivery fee', 'Free', valueColor: AppColors.success),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(double padding, double total, bool disabled) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        padding,
        16,
        padding,
        MediaQuery.paddingOf(context).bottom + 16,
      ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'Total',
                style: AppText.sans(size: 15, weight: FontWeight.w600),
              ),
              const Spacer(),
              BloomPrice(value: total, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _isPlacingOrder || disabled ? null : _placeOrder,
            child: _isPlacingOrder
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Place Order'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.coral),
        const SizedBox(width: 8),
        Text(title, style: AppText.serif(size: 18)),
      ],
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(label, style: AppText.sans(size: 13, color: AppColors.muted)),
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
