import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import '../../../widgets/bloom_animations.dart';
import '../../../widgets/bloom_ui.dart';
import '../../../widgets/product_card.dart';

class HomeBestSellers extends StatelessWidget {
  final double padding;
  final List<ProductModel> products;
  final Set<String> favoriteIds;
  final void Function(ProductModel product, String heroTag) onOpenProduct;
  final ValueChanged<ProductModel> onFavorite;
  final ValueChanged<ProductModel> onAdd;
  final VoidCallback onViewAll;

  const HomeBestSellers({
    super.key,
    required this.padding,
    required this.products,
    required this.favoriteIds,
    required this.onOpenProduct,
    required this.onFavorite,
    required this.onAdd,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final featured = products.take(6).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padding, 22, padding, 12),
          child: BloomSectionHeader(
            title: 'Best Sellers',
            actionLabel: 'View All',
            onAction: onViewAll,
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
                    onTap: () => onOpenProduct(product, tag),
                    onFavorite: () => onFavorite(product),
                    onAdd: () => onAdd(product),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
