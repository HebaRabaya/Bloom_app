import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/category_service.dart';
import '../../services/favorite_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_logo.dart';
import '../../widgets/bloom_ui.dart';
import '../../widgets/product_card.dart';
import 'favorites_screen.dart';
import 'product_details_screen.dart';
import 'search_screen.dart';
import 'user_main_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _productService = ProductService();
  final _categoryService = CategoryService();
  final _favoriteService = FavoriteService();
  final _cartService = CartService();

  // ============================================================
  // Actions
  // ============================================================

  Future<void> _addToCart(ProductModel product) async {
    try {
      await _cartService.addToCart(productId: product.id);
      if (!mounted) return;
      showBloomSnack(context, '${product.name} added to your cart');
    } catch (e) {
      if (!mounted) return;
      showBloomSnack(context, _friendlyError(e), isError: true);
    }
  }

  Future<void> _toggleFavorite(ProductModel product) async {
    try {
      await _favoriteService.toggleFavorite(product);
    } catch (e) {
      if (!mounted) return;
      showBloomSnack(context, _friendlyError(e), isError: true);
    }
  }

  String _friendlyError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _openProduct(ProductModel product, String heroTag) {
    Navigator.push(
      context,
      BloomPageRoute(
        builder: (_) => ProductDetailsScreen(
          product: product,
          heroTag: heroTag,
        ),
      ),
    );
  }

  void _openCategory(String name) {
    Navigator.push(
      context,
      BloomPageRoute(
        builder: (_) => SearchScreen(
          initialCategory: name,
          showBackButton: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final padding = bloomPagePadding(width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<Set<String>>(
          stream: _favoriteService.getFavoriteProductIds(),
          builder: (context, favoriteSnapshot) {
            final favoriteIds = favoriteSnapshot.data ?? <String>{};

            return StreamBuilder<List<ProductModel>>(
              stream: _productService.getProducts(),
              builder: (context, productSnapshot) {
                final products =
                    productSnapshot.data ?? const <ProductModel>[];
                final loading =
                    productSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    products.isEmpty;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(padding)),
                    SliverToBoxAdapter(child: _buildSearchBar(padding)),
                    SliverToBoxAdapter(child: _buildBanner(padding)),
                    SliverToBoxAdapter(child: _buildCategories(padding)),

                    if (loading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: BloomLoader(message: 'Gathering flowers…'),
                        ),
                      )
                    else if (products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: BloomEmptyState(
                          title: 'The shelves are still empty',
                          message:
                              'New arrangements are on their way. '
                              'Check back in a moment.',
                          icon: Icons.local_florist_rounded,
                        ),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: _buildBestSellers(
                          padding: padding,
                          products: products,
                          favoriteIds: favoriteIds,
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildPromo(padding)),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(padding, 24, padding, 8),
                        sliver: SliverToBoxAdapter(
                          child: BloomSectionHeader(
                            title: 'All Flowers',
                            actionLabel: 'Search',
                            onAction: () =>
                                UserMainScreen.of(context)?.goToTab(1),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(padding, 4, padding, 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: bloomGridCount(width),
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.68,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = products[index];
                              return FadeSlideIn.staggered(
                                index: index,
                                child: ProductCard(
                                  product: product,
                                  heroTag: 'home-${product.id}',
                                  isFavorite: favoriteIds.contains(product.id),
                                  onTap: () => _openProduct(
                                    product,
                                    'home-${product.id}',
                                  ),
                                  onFavorite: () => _toggleFavorite(product),
                                  onAdd: () => _addToCart(product),
                                ),
                              );
                            },
                            childCount: products.length,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // Header
  // ============================================================

  Widget _buildHeader(double padding) {
    return FadeSlideIn(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 6, padding, 4),
        child: Row(
          children: [
            BloomCircleButton(
              icon: Icons.favorite_border_rounded,
              color: AppColors.coral,
              onTap: () {
                Navigator.push(
                  context,
                  BloomPageRoute(builder: (_) => const FavoritesScreen()),
                );
              },
            ),
            Expanded(
              child: Column(
                children: [
                  const BloomMark(size: 26),
                  const SizedBox(height: 4),
                  Text('BLOOM', style: AppText.wordmark(size: 15)),
                ],
              ),
            ),
            BloomCircleButton(
              icon: Icons.search_rounded,
              onTap: () => UserMainScreen.of(context)?.goToTab(1),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Search bar
  // ============================================================

  Widget _buildSearchBar(double padding) {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 70),
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 14, padding, 0),
        child: PressableScale(
          onTap: () => UserMainScreen.of(context)?.goToTab(1),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 10),
                Text(
                  'Search for flowers…',
                  style: AppText.sans(size: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Hero banner
  // ============================================================

  Widget _buildBanner(double padding) {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 120),
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 18, padding, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(AppAssets.homeHeroBanner, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.blush.withValues(alpha: 0.97),
                        AppColors.blush.withValues(alpha: 0.72),
                        AppColors.blush.withValues(alpha: 0.0),
                      ],
                      stops: const [0, 0.42, 0.78],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                child: SizedBox(
                  width: 190,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BIGGER.',
                        style: AppText.serif(size: 21, height: 1.15),
                      ),
                      Text(
                        'BRIGHTER.',
                        style: AppText.serif(
                          size: 21,
                          height: 1.15,
                          color: AppColors.coral,
                        ),
                      ),
                      Text(
                        'BETTER.',
                        style: AppText.serif(size: 21, height: 1.15),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Thoughtfully designed flowers and gifts '
                        'for every meaningful moment.',
                        style: AppText.sans(
                          size: 11,
                          color: AppColors.ink.withValues(alpha: 0.72),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      PressableScale(
                        onTap: () => UserMainScreen.of(context)?.goToTab(1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.forest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Shop Now',
                                style: AppText.sans(
                                  size: 12,
                                  weight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Categories
  // ============================================================

  Widget _buildCategories(double padding) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _categoryService.getCategories(),
      builder: (context, snapshot) {
        final documents = snapshot.data?.docs ?? [];
        if (documents.isEmpty) return const SizedBox(height: 18);

        return FadeSlideIn(
          delay: const Duration(milliseconds: 170),
          child: Padding(
            padding: const EdgeInsets.only(top: 22),
            child: SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                itemCount: documents.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final name =
                      documents[index].data()['name']?.toString() ?? '';

                  return PressableScale(
                    onTap: () => _openCategory(name),
                    child: SizedBox(
                      width: 72,
                      child: Column(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.line,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: ClipOval(
                              child: Image.asset(
                                AppAssets.categoryFallback(name),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppText.sans(
                              size: 11,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // Best sellers
  // ============================================================

  Widget _buildBestSellers({
    required double padding,
    required List<ProductModel> products,
    required Set<String> favoriteIds,
  }) {
    final featured = products.take(6).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padding, 22, padding, 12),
          child: BloomSectionHeader(
            title: 'Best Sellers',
            actionLabel: 'View All',
            onAction: () => UserMainScreen.of(context)?.goToTab(1),
          ),
        ),
        SizedBox(
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: padding),
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final product = featured[index];
              final tag = 'best-${product.id}';

              return FadeSlideIn.staggered(
                index: index,
                offsetY: 0,
                child: SizedBox(
                  width: 152,
                  child: ProductCard(
                    product: product,
                    heroTag: tag,
                    isFavorite: favoriteIds.contains(product.id),
                    onTap: () => _openProduct(product, tag),
                    onFavorite: () => _toggleFavorite(product),
                    onAdd: () => _addToCart(product),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================
  // Promo card
  // ============================================================

  Widget _buildPromo(double padding) {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 120),
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 24, padding, 0),
        child: PressableScale(
          onTap: () => UserMainScreen.of(context)?.goToTab(1),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.creamDeep,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flowers for\nEvery Occasion',
                        style: AppText.serif(size: 19, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: AppText.sans(
                                size: 11.5,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    AppAssets.categoryOccasions,
                    width: 108,
                    height: 108,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
