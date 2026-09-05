import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/favorite_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';
import 'product_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoriteService = FavoriteService();
  final _cartService = CartService();

  Future<void> _remove(ProductModel product) async {
    try {
      await _favoriteService.removeFavorite(product.id);
      if (!mounted) return;
      showBloomSnack(context, '${product.name} removed from favorites');
    } catch (e) {
      if (!mounted) return;
      showBloomSnack(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> _addToCart(ProductModel product) async {
    try {
      await _cartService.addToCart(productId: product.id);
      if (!mounted) return;
      showBloomSnack(context, '${product.name} added to your cart');
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
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: BloomCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ),
        leadingWidth: 62,
        title: const Text('Favorites'),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _favoriteService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const BloomLoader();
          }

          final products = snapshot.data ?? const <ProductModel>[];

          if (products.isEmpty) {
            return BloomEmptyState(
              title: 'Nothing saved yet',
              message:
                  'Tap the heart on any bouquet and it will be waiting for '
                  'you here.',
              icon: Icons.favorite_border_rounded,
              actionLabel: 'Find something you love',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(padding, 8, padding, 40),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              final tag = 'fav-${product.id}';

              return FadeSlideIn.staggered(
                key: ValueKey(product.id),
                index: index,
                child: BloomCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      BloomPageRoute(
                        builder: (_) => ProductDetailsScreen(
                          product: product,
                          heroTag: tag,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: Hero(
                            tag: tag,
                            child: BloomImage(url: product.imageUrl),
                          ),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.sans(
                                size: 13.5,
                                weight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.category.isEmpty
                                  ? 'Flowers'
                                  : product.category,
                              style: AppText.sans(
                                size: 11.5,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                BloomPrice(value: product.price, size: 14),
                                const Spacer(),
                                if (product.quantity > 0)
                                  TextButton(
                                    onPressed: () => _addToCart(product),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Add to cart',
                                      style: AppText.sans(
                                        size: 11.5,
                                        weight: FontWeight.w600,
                                        color: AppColors.forest,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _remove(product),
                        icon: const Icon(
                          Icons.favorite,
                          size: 20,
                          color: AppColors.coral,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
