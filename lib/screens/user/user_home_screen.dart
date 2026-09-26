import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../models/product_model.dart';
import '../../providers/cart_providers.dart';
import '../../providers/category_providers.dart';
import '../../providers/favorite_providers.dart';
import '../../providers/product_providers.dart';
import '../../services/cart_service.dart';
import '../../services/category_service.dart';
import '../../services/favorite_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_luxe.dart';
import '../../widgets/bloom_ui.dart';
import '../../widgets/product_card.dart';
import 'home/home_best_sellers.dart';
import 'home/home_categories.dart';
import 'home/home_header.dart';
import 'home/home_hero_banner.dart';
import 'home/home_promo_card.dart';
import 'home/home_search_bar.dart';
import 'user_main_screen.dart';

class UserHomeScreen extends ConsumerStatefulWidget {
  const UserHomeScreen({super.key});

  @override
  ConsumerState<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends ConsumerState<UserHomeScreen> {
  ProductService get _productService => ref.read(productServiceProvider);
  CategoryService get _categoryService => ref.read(categoryServiceProvider);
  FavoriteService get _favoriteService => ref.read(favoriteServiceProvider);
  CartService get _cartService => ref.read(cartServiceProvider);
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

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
    context.push(
      AppRoutes.product,
      extra: ProductRouteExtra(product: product, heroTag: heroTag),
    );
  }

  void _openCategory(String name) {
    context.push(
      Uri(
        path: AppRoutes.search,
        queryParameters: {'category': name, 'back': '1'},
      ).toString(),
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
                final products = productSnapshot.data ?? const <ProductModel>[];
                final loading =
                    productSnapshot.connectionState ==
                        ConnectionState.waiting &&
                    products.isEmpty;

                return CustomScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    CupertinoSliverRefreshControl(
                      refreshTriggerPullDistance: 120,
                      refreshIndicatorExtent: 76,
                      onRefresh: () async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 1100),
                        );
                      },
                      builder:
                          (
                            context,
                            refreshState,
                            pulledExtent,
                            triggerDistance,
                            indicatorExtent,
                          ) {
                            final progress = (pulledExtent / triggerDistance)
                                .clamp(0.0, 1.0);
                            return BloomRefreshLotus(
                              progress: progress,
                              refreshing:
                                  refreshState ==
                                      RefreshIndicatorMode.refresh ||
                                  refreshState == RefreshIndicatorMode.done,
                            );
                          },
                    ),
                    SliverToBoxAdapter(child: HomeHeader(padding: padding)),
                    SliverToBoxAdapter(child: HomeSearchBar(padding: padding)),
                    SliverToBoxAdapter(
                      child: AnimatedBuilder(
                        animation: _scroll,
                        builder: (context, _) {
                          return HomeHeroBanner(
                            padding: padding,
                            parallax: _scroll.hasClients ? _scroll.offset : 0,
                          );
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: HomeCategories(
                        padding: padding,
                        stream: _categoryService.getCategories(),
                        onCategoryTap: _openCategory,
                      ),
                    ),

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
                        child: HomeBestSellers(
                          padding: padding,
                          products: products,
                          favoriteIds: favoriteIds,
                          onOpenProduct: _openProduct,
                          onFavorite: _toggleFavorite,
                          onAdd: _addToCart,
                          onViewAll: () =>
                              UserMainScreen.of(context)?.goToTab(1),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: HomePromoCard(padding: padding),
                      ),
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
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = products[index];
                            return FadeSlideIn.staggered(
                              index: index,
                              child: ProductCard(
                                product: product,
                                heroTag: 'home-${product.id}',
                                isFavorite: favoriteIds.contains(product.id),
                                onTap: () =>
                                    _openProduct(product, 'home-${product.id}'),
                                onFavorite: () => _toggleFavorite(product),
                                onAdd: () => _addToCart(product),
                              ),
                            );
                          }, childCount: products.length),
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
}
