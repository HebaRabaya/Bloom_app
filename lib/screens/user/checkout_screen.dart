import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_providers.dart';
import '../../providers/order_providers.dart';
import '../../providers/profile_providers.dart';
import '../../services/cart_service.dart';
import '../../services/gift_message_service.dart';
import '../../services/order_service.dart';
import '../../services/profile_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';
import '../../widgets/order_status.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const _cities = [
    'Ramallah',
    'Bethlehem',
    'Nablus',
    'Jerusalem',
    'Hebron',
  ];

  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _messageController = TextEditingController();
  final _writer = GiftMessageService();
  final _messageKey = GlobalKey();

  OrderService get _orderService => ref.read(orderServiceProvider);
  ProfileService get _profileService => ref.read(profileServiceProvider);
  CartService get _cartService => ref.read(cartServiceProvider);

  bool _isLoadingAddress = true;
  bool _isPlacingOrder = false;
  String _occasion = GiftMessageService.occasions.first;
  String _tone = GiftMessageService.tones.first;
  DateTime _deliveryDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onDraftChanged);
    _cityController.addListener(_onDraftChanged);
    _loadAddress();
  }

  @override
  void dispose() {
    _messageController.removeListener(_onDraftChanged);
    _cityController.removeListener(_onDraftChanged);
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onDraftChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) setState(() => _isLoadingAddress = false);
      return;
    }

    try {
      final profile = await _profileService.getProfile(user.uid);
      _recipientNameController.text = profile?.name ?? '';
      _recipientPhoneController.text = profile?.phone ?? '';
      _addressController.text = profile?.address ?? '';
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to load your saved address.');
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();

    final recipientName = _recipientNameController.text.trim();
    final recipientPhone = _recipientPhoneController.text.trim();
    final city = _cityController.text.trim();
    final address = _addressController.text.trim();

    if (recipientName.isEmpty) {
      showBloomSnack(context, 'Please enter the recipient\'s name.', isError: true);
      return;
    }
    if (recipientPhone.isEmpty) {
      showBloomSnack(context, 'Please enter the recipient\'s phone.', isError: true);
      return;
    }
    if (city.isEmpty) {
      showBloomSnack(context, 'Please enter the delivery city or area.', isError: true);
      return;
    }
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
      final orderId = await _orderService.checkout(
        address: address,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        city: city,
        deliveryDate: _isoDate(_deliveryDate),
        deliveryNotes: _notesController.text.trim(),
        giftMessage: _messageController.text.trim(),
        occasion: _occasion,
      );

      if (!mounted) return;

      context.pushReplacement(
        Uri(
          path: AppRoutes.orderSuccess,
          queryParameters: {'orderId': orderId},
        ).toString(),
      );
    } catch (e) {
      if (!mounted) return;
      showBloomSnack(context, _checkoutError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  void _writeMessage() {
    final message = _writer.write(
      occasion: _occasion,
      tone: _tone,
      recipientName: _recipientNameController.text,
    );
    _messageController.value = TextEditingValue(
      text: message,
      selection: TextSelection.collapsed(offset: message.length),
    );
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _messageKey.currentContext;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.15,
      );
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate.isBefore(today) ? today : _deliveryDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 21)),
    );
    if (picked == null) return;
    setState(() => _deliveryDate = picked);
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
            onTap: () => context.pop(),
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
                          FadeSlideIn(child: _buildRecipientSection()),
                          const SizedBox(height: 22),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 70),
                            child: _buildMessageSection(),
                          ),
                          const SizedBox(height: 22),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 120),
                            child: _buildDeliverySection(),
                          ),
                          const SizedBox(height: 22),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 160),
                            child: _buildPaymentSection(),
                          ),
                          const SizedBox(height: 22),
                          FadeSlideIn(
                            delay: const Duration(milliseconds: 200),
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

  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Recipient', Icons.card_giftcard_outlined),
        const SizedBox(height: 6),
        Text(
          'Who should receive the flowers?',
          style: AppText.sans(size: 12.5, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        _field(
          controller: _recipientNameController,
          label: 'Recipient name',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 12),
        _field(
          controller: _recipientPhoneController,
          label: 'Recipient phone',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Delivery', Icons.local_shipping_outlined),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final city in _cities)
              BloomChip(
                label: city,
                selected: _cityController.text.trim() == city,
                onTap: () => setState(() => _cityController.text = city),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _field(
          controller: _cityController,
          label: 'City / area',
          icon: Icons.map_outlined,
        ),
        const SizedBox(height: 12),
        _field(
          controller: _addressController,
          label: 'Street, building, landmark',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(18),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Delivery date',
                prefixIcon: Icon(Icons.event_outlined, size: 19),
              ),
              child: Text(
                OrderStatusInfo.formatDay(_isoDate(_deliveryDate)),
                style: AppText.sans(size: 13.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _field(
          controller: _notesController,
          label: 'Delivery notes (optional)',
          icon: Icons.notes_outlined,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildMessageSection() {
    final hasMessage = _messageController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Gift message', Icons.mail_outline_rounded),
        const SizedBox(height: 6),
        Text(
          'Add a card, or let Bloom write one for you.',
          style: AppText.sans(size: 12.5, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final occasion in GiftMessageService.occasions)
              BloomChip(
                label: occasion,
                selected: occasion == _occasion,
                onTap: () => setState(() => _occasion = occasion),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tone in GiftMessageService.tones)
              BloomChip(
                label: tone,
                selected: tone == _tone,
                onTap: () => setState(() => _tone = tone),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _writeMessage,
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(hasMessage ? 'Write another' : 'Write with Bloom'),
          ),
        ),
        const SizedBox(height: 12),
        BloomCard(
          key: _messageKey,
          padding: const EdgeInsets.all(16),
          child: Text(
            hasMessage
                ? _messageController.text
                : 'Press Write with Bloom and the card message appears here. You can edit it afterwards.',
            style: hasMessage
                ? AppText.serif(size: 18, height: 1.35)
                : AppText.sans(size: 13, color: AppColors.muted, height: 1.5),
          ),
        ),
        if (hasMessage) ...[
          const SizedBox(height: 12),
          _field(
            controller: _messageController,
            label: 'Edit the message',
            icon: Icons.edit_outlined,
            maxLines: 4,
          ),
        ],
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppText.sans(size: 13.5),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: maxLines > 1
            ? Padding(
                padding: EdgeInsets.only(bottom: 18.0 * (maxLines - 1)),
                child: Icon(icon, size: 19),
              )
            : Icon(icon, size: 19),
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

  static String _isoDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String _money(double value) {
    return value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2);
  }
}
