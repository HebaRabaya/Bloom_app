import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../services/order_service.dart';

class ProductDetailsScreen
    extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen>
  createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  final OrderService _orderService =
  OrderService();

  bool _isOrdering = false;

  // ============================================================
  // Order Product
  // ============================================================

  Future<void> _orderProduct() async {
    if (_isOrdering) {
      return;
    }

    if (widget.product.quantity <= 0) {
      _showMessage(
        'This product is out of stock.',
      );
      return;
    }

    setState(() {
      _isOrdering = true;
    });

    try {
      await _orderService.createOrder(
        productId: widget.product.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Order placed successfully 🌷',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      final error =
      e.toString().toLowerCase();

      String message =
          'Unable to place order.';

      if (error.contains(
          'out of stock')) {
        message =
        'This product is out of stock.';
      } else if (error.contains(
          'product not found')) {
        message =
        'This product is no longer available.';
      }

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isOrdering = false;
        });
      }
    }
  }

  // ============================================================
  // Message
  // ============================================================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
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
  // Build
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final product =
        widget.product;

    final isOutOfStock =
        product.quantity <= 0;

    return Scaffold(
      backgroundColor:
      const Color(0xFFF9F4F1),

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons
                .arrow_back_ios_new_rounded,
            color:
            Color(0xFF4B3439),
          ),
        ),

        title: Text(
          'Product Details',
          style:
          GoogleFonts.playfairDisplay(
            fontSize: 23,
            fontWeight:
            FontWeight.w600,
            color:
            const Color(0xFF4B3439),
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
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
            // Image
            // ==================================================

            ClipRRect(
              borderRadius:
              BorderRadius.circular(25),

              child: SizedBox(
                width: double.infinity,
                height: 330,

                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,

                  errorBuilder:
                      (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color: Colors.white,

                      child:
                      const Center(
                        child: Icon(
                          Icons
                              .image_not_supported_outlined,
                          size: 60,
                          color: Color(
                              0xFFB86F7B),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // Category
            // ==================================================

            Container(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 12,
                vertical: 6,
              ),

              decoration:
              BoxDecoration(
                color:
                const Color(
                    0xFFE8D1D4),
                borderRadius:
                BorderRadius.circular(
                    20),
              ),

              child: Text(
                product.category,
                style:
                GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  const Color(
                      0xFF8C626B),
                ),
              ),
            ),

            const SizedBox(
              height: 14,
            ),

            // ==================================================
            // Name + Price
            // ==================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: GoogleFonts
                        .playfairDisplay(
                      fontSize: 30,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      const Color(
                          0xFF4B3439),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Text(
                  '\$${product.price}',
                  style:
                  GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                        0xFFB86F7B),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 20,
            ),

            // ==================================================
            // Description
            // ==================================================

            Text(
              'About this product',
              style:
              GoogleFonts.playfairDisplay(
                fontSize: 21,
                fontWeight:
                FontWeight.w600,
                color:
                const Color(
                    0xFF4B3439),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              product.description,
              style:
              GoogleFonts.dmSans(
                fontSize: 14,
                height: 1.6,
                color:
                const Color(
                    0xFF7D696D),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            // ==================================================
            // Stock
            // ==================================================

            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(
                  16),

              decoration:
              BoxDecoration(
                color: isOutOfStock
                    ? const Color(
                    0xFFF4DEDE)
                    : const Color(
                    0xFFE8F1E6),

                borderRadius:
                BorderRadius.circular(
                    18),
              ),

              child: Row(
                children: [
                  Icon(
                    isOutOfStock
                        ? Icons
                        .cancel_outlined
                        : Icons
                        .check_circle_outline,

                    color:
                    isOutOfStock
                        ? Colors.red
                        : Colors.green,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      isOutOfStock
                          ? 'This product is currently out of stock.'
                          : '${product.quantity} items available',

                      style:
                      GoogleFonts.dmSans(
                        fontWeight:
                        FontWeight.w600,
                        color:
                        isOutOfStock
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            // ==================================================
            // Order Button
            // ==================================================

            SizedBox(
              width: double.infinity,
              height: 58,

              child:
              ElevatedButton(
                onPressed:
                isOutOfStock ||
                    _isOrdering
                    ? null
                    : _orderProduct,

                style: ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  const Color(
                      0xFFB86F7B),

                  foregroundColor:
                  Colors.white,

                  disabledBackgroundColor:
                  const Color(
                      0xFFD8C9C9),

                  elevation: 0,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        18),
                  ),
                ),

                child: _isOrdering
                    ? const SizedBox(
                  width: 23,
                  height: 23,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                    Colors.white,
                  ),
                )
                    : Text(
                  isOutOfStock
                      ? 'Out of Stock'
                      : 'Order Now',

                  style:
                  GoogleFonts.dmSans(
                    fontSize: 16,
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
}