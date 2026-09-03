import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../services/cart_service.dart';
import '../../services/category_service.dart';
import '../../services/favorite_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';
import '../../widgets/product_card.dart';
import 'product_details_screen.dart';

/// Browse and filter the catalogue. Doubles as the category listing when
/// opened from the home screen with [initialCategory].
class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  final bool showBackButton;

  const SearchScreen({
    super.key,
    this.initialCategory,
    this.showBackButton = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _productService = ProductService();
  final _categoryService = CategoryService();
  final _favoriteService = FavoriteService();
  final _cartService = CartService();
  final _searchController = TextEditingController();

  String _query = '';
  late String _selectedCategory = widget.initialCategory ?? 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filter(List<ProductModel> products) {
    final query = _query.trim().toLowerCase();

    return products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' ||
          product.category.toLowerCase() == _selectedCategory.toLowerCase();

      final matchesQuery =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
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

  Future<void> _toggleFavorite(ProductModel product) async {
    try {
      await _favoriteService.toggleFavorite(product);
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
    final width = MediaQuery.sizeOf(context).width;
    final padding = bloomPagePadding(width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(padding),
            _buildCategoryFilters(padding),
            Expanded(
              child: StreamBuilder<Set<String>>(
                stream: _favoriteService.getFavoriteProductIds(),
                builder: (context, favoriteSnapshot) {
                  final favoriteIds = favoriteSnapshot.data ?? <String>{};

                  return StreamBuilder<List<ProductModel>>(
                    stream: _productService.getProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                              ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const BloomLoader();
                      }

                      final results = _filter(
                        snapshot.data ?? const <ProductModel>[],
                      );

                      if (results.isEmpty) {
                        return BloomEmptyState(
                          title: 'No matches found',
                          message: _query.isEmpty
                              ? 'There is nothing in this category yet. '
                                    'Try another one.'
                              : 'We could not find "$_query". '
                                    'Try a different flower or occasion.',
                          icon: Icons.search_off_rounded,
                          actionLabel: _query.isEmpty ? null : 'Clear search',
                          onAction: _query.isEmpty
                              ? null
                              : () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                        );
                      }

                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(padding, 6, padding, 20),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: bloomGridCount(width),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.68,
                            ),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final product = results[index];
                          final tag = 'search-${product.id}';

                          return FadeSlideIn.staggered(
                            index: index,
                            child: ProductCard(
                              product: product,
                              heroTag: tag,
                              isFavorite: favoriteIds.contains(product.id),
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
                              onFavorite: () => _toggleFavorite(product),
                              onAdd: () => _addToCart(product),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 0),
      child: Row(
        children: [
          if (widget.showBackButton) ...[
            BloomCircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.line),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.search_rounded,
                    size: 19,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      textInputAction: TextInputAction.search,
                      style: AppText.sans(size: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Search roses, plants, gifts…',
                        hintStyle: AppText.sans(
                          size: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.muted,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(double padding) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _categoryService.getCategories(),
      builder: (context, snapshot) {
        final names = <String>['All'];

        for (final document in snapshot.data?.docs ?? []) {
          final name = document.data()['name']?.toString() ?? '';
          if (name.isNotEmpty) names.add(name);
        }

        // Keep a category opened from home visible even if it was removed.
        if (!names.contains(_selectedCategory)) {
          names.add(_selectedCategory);
        }

        return SizedBox(
          height: 62,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(padding, 14, padding, 10),
            itemCount: names.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final name = names[index];
              return BloomChip(
                label: name,
                selected: name == _selectedCategory,
                onTap: () => setState(() => _selectedCategory = name),
              );
            },
          ),
        );
      },
    );
  }
}
