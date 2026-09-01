import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/cart_model.dart';
import '../../services/order_service.dart';
import '../../services/profile_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartModel> items;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.items,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState
    extends State<CheckoutScreen> {

  // ============================================================
  // Controllers
  // ============================================================

  final TextEditingController
  _addressController =
  TextEditingController();

  // ============================================================
  // Services
  // ============================================================

  final OrderService _orderService =
  OrderService();

  final ProfileService _profileService =
  ProfileService();

  // ============================================================
  // States
  // ============================================================

  bool _isLoadingAddress = true;
  bool _isCheckingOut = false;

  // ============================================================
  // Init
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadAddress();
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _addressController.dispose();

    super.dispose();
  }

  // ============================================================
  // Load Saved Address
  // ============================================================
  // أول ما تفتح شاشة Checkout،
  // بنجيب العنوان المحفوظ سابقًا من Firestore.
  // ============================================================

  Future<void> _loadAddress() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }

      return;
    }

    try {
      final document =
      await _profileService.getProfile(
        user.uid,
      );

      final data =
      document.data();

      _addressController.text =
          data?['address']
              ?.toString() ??
              '';
    } catch (e) {
      _showMessage(
        'Unable to load your address.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  // ============================================================
  // Place Order
  // ============================================================
  // هذه هي العملية الرئيسية للـ Checkout.
  //
  // قبل إنشاء الطلب:
  // 1. نتأكد من العنوان.
  // 2. نخزن العنوان في Profile.
  //
  // بعدها OrderService ينفذ:
  // 1. Create Order
  // 2. Decrease Stock
  // 3. Clear Cart
  // ============================================================

  Future<void> _placeOrder() async {
    final address =
    _addressController.text.trim();

    // ----------------------------------------------------------
    // Validate Address
    // ----------------------------------------------------------

    if (address.isEmpty) {
      _showMessage(
        'Please enter your delivery address.',
      );

      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage(
        'No logged-in user found.',
      );

      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      // ========================================================
      // Save Address
      // ========================================================

      await _profileService.saveAddress(
        uid: user.uid,
        address: address,
      );

      // ========================================================
      // Checkout
      // ========================================================
      // OrderService ينفذ دورة الشراء كاملة:
      //
      // 1. Create Order
      // 2. Decrease Stock
      // 3. Clear Cart
      // ========================================================

      await _orderService.checkout(
        address: address,
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // Return To Cart
      // ========================================================
      // بعد نجاح العملية، Stream السلة رح يتحدث تلقائيًا
      // وتظهر فاضية.
      // ========================================================

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Order placed successfully 🌷',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _getCheckoutErrorMessage(e),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  // ============================================================
  // Checkout Error Message
  // ============================================================

  String _getCheckoutErrorMessage(
      Object error,
      ) {
    final message =
    error.toString();

    if (message.contains(
      'Not enough stock',
    )) {
      return message
          .replaceFirst(
        'Exception: ',
        '',
      );
    }

    if (message.contains(
      'cart is empty',
    )) {
      return 'Your cart is empty.';
    }

    if (message.contains(
      'address',
    )) {
      return 'Please enter your delivery address.';
    }

    return 'Unable to complete checkout.';
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF9F4F1),

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        centerTitle: true,

        title: Text(
          'Checkout',
          style:
          GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight:
            FontWeight.w600,
            color:
            const Color(0xFF4B3439),
          ),
        ),
      ),

      body: _isLoadingAddress
          ? const Center(
        child:
        CircularProgressIndicator(
          color:
          Color(0xFFB86F7B),
        ),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          30,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ==================================================
            // Delivery Address
            // ==================================================

            _buildSectionTitle(
              'Delivery Address',
              'Where should we deliver your order?',
            ),

            const SizedBox(
              height: 14,
            ),

            TextField(
              controller:
              _addressController,

              maxLines: 3,

              style:
              GoogleFonts.dmSans(
                fontSize: 14,
                color:
                const Color(
                  0xFF4B3439,
                ),
              ),

              decoration:
              InputDecoration(
                hintText:
                'Enter your full delivery address',

                prefixIcon:
                const Padding(
                  padding:
                  EdgeInsets.only(
                    bottom: 45,
                  ),
                  child: Icon(
                    Icons
                        .location_on_outlined,
                    color:
                    Color(
                      0xFFB86F7B,
                    ),
                  ),
                ),

                filled: true,

                fillColor:
                Colors.white,

                contentPadding:
                const EdgeInsets
                    .symmetric(
                  horizontal: 18,
                  vertical: 17,
                ),

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    17,
                  ),
                  borderSide:
                  BorderSide.none,
                ),

                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    17,
                  ),
                  borderSide:
                  BorderSide.none,
                ),

                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    17,
                  ),
                  borderSide:
                  const BorderSide(
                    color:
                    Color(
                      0xFFD39AA4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // Order Summary
            // ==================================================

            _buildSectionTitle(
              'Order Summary',
              'Review your products before placing the order.',
            ),

            const SizedBox(
              height: 14,
            ),

            ...widget.items.map(
                  (item) =>
                  _buildOrderItem(
                    item,
                  ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // Total
            // ==================================================

            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius
                    .circular(
                  20,
                ),
              ),

              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total',
                      style:
                      GoogleFonts
                          .dmSans(
                        fontSize: 17,
                        fontWeight:
                        FontWeight
                            .w700,
                        color:
                        const Color(
                          0xFF4B3439,
                        ),
                      ),
                    ),
                  ),

                  Text(
                    '\$${widget.totalAmount.toStringAsFixed(2)}',

                    style:
                    GoogleFonts
                        .dmSans(
                      fontSize: 20,
                      fontWeight:
                      FontWeight
                          .w700,
                      color:
                      const Color(
                        0xFFB86F7B,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            // ==================================================
            // Place Order Button
            // ==================================================

            SizedBox(
              width:
              double.infinity,

              height: 56,

              child:
              ElevatedButton(
                onPressed:
                _isCheckingOut
                    ? null
                    : _placeOrder,

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  const Color(
                    0xFFB86F7B,
                  ),

                  foregroundColor:
                  Colors.white,

                  disabledBackgroundColor:
                  const Color(
                    0xFFD7B9BE,
                  ),

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      17,
                    ),
                  ),
                ),

                child:
                _isCheckingOut
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                    color:
                    Colors.white,
                  ),
                )
                    : Text(
                  'Place Order',

                  style:
                  GoogleFonts
                      .dmSans(
                    fontSize:
                    15,
                    fontWeight:
                    FontWeight
                        .w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Section Title
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style:
          GoogleFonts.playfairDisplay(
            fontSize: 23,
            fontWeight:
            FontWeight.w600,
            color:
            const Color(0xFF4B3439),
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          subtitle,

          style:
          GoogleFonts.dmSans(
            fontSize: 13,
            color:
            const Color(0xFF92797E),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Order Item
  // ============================================================

  Widget _buildOrderItem(
      CartModel item,
      ) {
    final itemTotal =
        item.productPrice *
            item.quantity;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
      const EdgeInsets.all(
        12,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              13,
            ),

            child: SizedBox(
              width: 65,
              height: 65,

              child: Image.network(
                item.productImage,

                fit: BoxFit.cover,

                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return Container(
                    color:
                    const Color(
                      0xFFF4E8E5,
                    ),

                    child:
                    const Icon(
                      Icons
                          .image_not_supported_outlined,
                      color:
                      Color(
                        0xFFB86F7B,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  item.productName,

                  maxLines: 2,

                  overflow:
                  TextOverflow.ellipsis,

                  style:
                  GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                      0xFF4B3439,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  'Qty: ${item.quantity}',

                  style:
                  GoogleFonts.dmSans(
                    fontSize: 12,
                    color:
                    const Color(
                      0xFF92797E,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Text(
            '\$${itemTotal.toStringAsFixed(2)}',

            style:
            GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
              color:
              const Color(
                0xFFB86F7B,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SnackBar
  // ============================================================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(message),

        behavior:
        SnackBarBehavior.floating,

        backgroundColor:
        const Color(0xFF5A3D43),

        margin:
        const EdgeInsets.all(
          16,
        ),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }
}