import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/cart_model.dart';
import '../../services/cart_service.dart';

class CartScreen extends StatelessWidget {
  CartScreen({
    super.key,
  });

  final CartService _cartService =
  CartService();

  // ============================================================
  // Calculate Subtotal
  // ============================================================

  double _calculateSubtotal(
      List<CartModel> items,
      ) {
    double total = 0;

    for (final item in items) {
      total +=
          item.productPrice *
              item.quantity;
    }

    return total;
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
          'My Cart',
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

      // ========================================================
      // Cart Stream
      // ========================================================

      body: StreamBuilder<List<CartModel>>(
        stream:
        _cartService.getCart(),

        builder:
            (context, snapshot) {
          // ====================================================
          // Error
          // ====================================================

          if (snapshot.hasError) {
            return _buildMessage(
              icon:
              Icons.error_outline_rounded,
              title:
              'Something went wrong',
              subtitle:
              'We could not load your cart.',
            );
          }

          // ====================================================
          // Loading
          // ====================================================

          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(
                color:
                Color(0xFFB86F7B),
              ),
            );
          }

          final items =
          snapshot.data!;

          // ====================================================
          // Empty Cart
          // ====================================================

          if (items.isEmpty) {
            return _buildMessage(
              icon:
              Icons.shopping_bag_outlined,
              title:
              'Your cart is empty',
              subtitle:
              'Add some beautiful flowers to your cart 🌷',
            );
          }

          // ====================================================
          // Subtotal
          // ====================================================

          final subtotal =
          _calculateSubtotal(items);

          // ====================================================
          // Cart Content
          // ====================================================

          return Column(
            children: [
              // ==================================================
              // Products
              // ==================================================

              Expanded(
                child:
                ListView.separated(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    10,
                    16,
                    20,
                  ),

                  itemCount:
                  items.length,

                  separatorBuilder:
                      (_, _) =>
                  const SizedBox(
                    height: 14,
                  ),

                  itemBuilder:
                      (context, index) {
                    return _buildCartItem(
                      context,
                      items[index],
                    );
                  },
                ),
              ),

              // ==================================================
              // Subtotal
              // ==================================================

              _buildSubtotal(
                context,
                subtotal,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // Cart Item
  // ============================================================

  Widget _buildCartItem(
      BuildContext context,
      CartModel item,
      ) {
    final canIncrease =
        item.quantity <
            item.availableQuantity;

    return Container(
      padding:
      const EdgeInsets.all(12),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: 0.04,
            ),

            blurRadius: 14,

            offset:
            const Offset(0, 5),
          ),
        ],
      ),

      child: Row(
        children: [
          // ==================================================
          // Product Image
          // ==================================================

          ClipRRect(
            borderRadius:
            BorderRadius.circular(15),

            child: SizedBox(
              width: 90,
              height: 90,

              child: Image.network(
                item.productImage,

                fit: BoxFit.cover,

                errorBuilder:
                    (context, error, stackTrace) {
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
                      Color(0xFFB86F7B),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 14),

          // ==================================================
          // Product Info
          // ==================================================

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
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                      0xFF4B3439,
                    ),
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  '\$${item.productPrice.toStringAsFixed(2)}',

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

                const SizedBox(height: 10),

                // ==============================================
                // Quantity Controls
                // ==============================================

                Row(
                  children: [
                    // ==========================================
                    // Minus
                    // ==========================================

                    _buildQuantityButton(
                      icon:
                      Icons.remove,

                      onPressed: () async {
                        try {
                          await _cartService
                              .decreaseQuantity(
                            item,
                          );
                        } catch (e) {
                          if (!context.mounted) {
                            return;
                          }

                          _showMessage(
                            context,
                            'Unable to update quantity.',
                          );
                        }
                      },
                    ),

                    // ==========================================
                    // Current Quantity
                    // ==========================================

                    Padding(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 12,
                      ),

                      child: Text(
                        '${item.quantity}',

                        style:
                        GoogleFonts.dmSans(
                          fontWeight:
                          FontWeight.w700,
                          color:
                          const Color(
                            0xFF4B3439,
                          ),
                        ),
                      ),
                    ),

                    // ==========================================
                    // Plus
                    // ==========================================

                    _buildQuantityButton(
                      icon:
                      Icons.add,

                      // إذا وصلنا لكمية المخزون
                      // الزر يصير disabled
                      onPressed:
                      canIncrease
                          ? () async {
                        try {
                          await _cartService
                              .increaseQuantity(
                            item,
                          );
                        } catch (e) {
                          if (!context
                              .mounted) {
                            return;
                          }

                          _showMessage(
                            context,
                            'Maximum available quantity reached.',
                          );
                        }
                      }
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==================================================
          // Delete
          // ==================================================

          IconButton(
            onPressed: () async {
              try {
                await _cartService
                    .removeFromCart(
                  item.productId,
                );
              } catch (e) {
                if (!context.mounted) {
                  return;
                }

                _showMessage(
                  context,
                  'Unable to remove product.',
                );
              }
            },

            icon: const Icon(
              Icons.delete_outline_rounded,
              color:
              Color(0xFFB86F7B),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Quantity Button
  // ============================================================

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 32,
      height: 32,

      child: IconButton(
        padding: EdgeInsets.zero,

        onPressed: onPressed,

        icon: Icon(
          icon,
          size: 17,
        ),

        style:
        IconButton.styleFrom(
          backgroundColor:
          const Color(0xFFF4E8E5),

          foregroundColor:
          const Color(0xFF7D5961),

          disabledBackgroundColor:
          const Color(0xFFEDE6E4),

          disabledForegroundColor:
          const Color(0xFFB9ACAC),
        ),
      ),
    );
  }

  // ============================================================
  // Subtotal
  // ============================================================

  Widget _buildSubtotal(
      BuildContext context,
      double subtotal,
      ) {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20,
      ),

      decoration:
      const BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.vertical(
          top:
          Radius.circular(25),
        ),
      ),

      child: SafeArea(
        top: false,

        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    'Subtotal',

                    style:
                    GoogleFonts.dmSans(
                      fontSize: 13,
                      color:
                      const Color(
                        0xFF92797E,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',

                    style:
                    GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      const Color(
                        0xFF4B3439,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // Checkout
            // ==================================================

            SizedBox(
              height: 50,

              child: ElevatedButton(
                onPressed: () {
                  _showMessage(
                    context,
                    'Checkout will be added later.',
                  );
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFFB86F7B,
                  ),

                  foregroundColor:
                  Colors.white,

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                child: Text(
                  'Checkout',

                  style:
                  GoogleFonts.dmSans(
                    fontWeight:
                    FontWeight.w700,
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
  // SnackBar Message
  // ============================================================

  void _showMessage(
      BuildContext context,
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
        const EdgeInsets.all(16),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // Empty / Error Message
  // ============================================================

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              icon,

              size: 70,

              color:
              const Color(
                0xFFB86F7B,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              title,

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight:
                FontWeight.w600,
                color:
                const Color(
                  0xFF4B3439,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.dmSans(
                fontSize: 13,
                color:
                const Color(
                  0xFF92797E,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}