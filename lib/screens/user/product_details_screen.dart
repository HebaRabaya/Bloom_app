import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/favorite_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final String heroTag;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.heroTag,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final _cartService = CartService();
  final _favoriteService = FavoriteService();

  int _quantity = 1;
  bool _isAdding = false;

  static const List<(IconData, String)> _highlights = [
    (Icons.local_florist_rounded, 'Fresh Flowers'),
    (Icons.local_shipping_outlined, 'Same-Day Delivery'),
    (Icons.volunteer_activism_outlined, 'Handmade'),
  ];

  ProductModel get _product => widget.product;

  // ============================================================
  // Add to cart
  // ============================================================

  Future<void> _addToCart() async {
    setState(() => _isAdding = true);

    try {
      // The service validates stock on every call, so we add one unit at a
      // time to keep that protection intact.
      for (var i = 0; i < _quantity; i++) {
        await _cartService.addToCart(productId: _product.id);
      }

      if (!mounted) return;
      showBloomSnack(
        context,
        '$_quantity × ${_product.name} added to your cart',
      );
    } catch (e) {
      if (!mounted) return;
      showBloomSnack(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      await _favoriteService.toggleFavorite(_product);
    } catch (e) {
      if (!mounted) return;
      showBloomSnack(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageHeight = (size.height * 0.44).clamp(260.0, 420.0);
    final outOfStock = _product.quantity <= 0;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Hero(
                    tag: widget.heroTag,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(34),
                      ),
                      child: BloomImage(url: _product.imageUrl),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlideIn(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _product.name,
                                style: AppText.serif(size: 25, height: 1.25),
                              ),
                            ),
                            const SizedBox(width: 12),
                            BloomPrice(value: _product.price, size: 22),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 70),
                        child: Row(
                          children: [
                            _tag(
                              _product.category.isEmpty
                                  ? 'Flowers'
                                  : _product.category,
                              AppColors.forestSoft,
                              AppColors.forest,
                            ),
                            const SizedBox(width: 8),
                            _tag(
                              outOfStock
                                  ? 'Sold out'
                                  : _product.quantity <= 5
                                  ? 'Only ${_product.quantity} left'
                                  : 'In stock',
                              outOfStock ? AppColors.blush : Colors.white,
                              outOfStock
                                  ? AppColors.danger
                                  : AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 120),
                        child: Text(
                          _product.description.trim().isEmpty
                              ? 'A beautiful mix of seasonal blooms, arranged '
                                    'by hand and wrapped with care.'
                              : _product.description,
                          style: AppText.sans(
                            size: 13.5,
                            color: AppColors.muted,
                            height: 1.75,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 170),
                        child: Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: [
                            for (final highlight in _highlights)
                              _highlightChip(highlight.$1, highlight.$2),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),

                      FadeSlideIn(
                        delay: const Duration(milliseconds: 220),
                        child: Row(
                          children: [
                            Text(
                              'Quantity',
                              style: AppText.sans(
                                size: 14,
                                weight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            BloomQuantityStepper(
                              quantity: _quantity,
                              onDecrease: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              onIncrease:
                                  _quantity < _product.quantity
                                  ? () => setState(() => _quantity++)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating controls over the artwork.
          Positioned(
            top: MediaQuery.paddingOf(context).top + 10,
            left: 20,
            right: 20,
            child: Row(
              children: [
                BloomCircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                StreamBuilder<Set<String>>(
                  stream: _favoriteService.getFavoriteProductIds(),
                  builder: (context, snapshot) {
                    final isFavorite =
                        snapshot.data?.contains(_product.id) ?? false;

                    return BloomCircleButton(
                      icon: isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_rounded,
                      color: AppColors.coral,
                      onTap: _toggleFavorite,
                    );
                  },
                ),
              ],
            ),
          ),

          // Sticky purchase bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MediaQuery.paddingOf(context).bottom + 18,
              ),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.taupe.withValues(alpha: 0.22),
                    blurRadius: 26,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: AppText.sans(size: 11, color: AppColors.muted),
                      ),
                      BloomPrice(
                        value: _product.price * _quantity,
                        size: 19,
                      ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: outOfStock || _isAdding ? null : _addToCart,
                      child: _isAdding
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(outOfStock ? 'Sold out' : 'Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
      ),
      child: Text(
        label,
        style: AppText.sans(
          size: 11,
          weight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }

  Widget _highlightChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.coral),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.sans(size: 11.5, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
