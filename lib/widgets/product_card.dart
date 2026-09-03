import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'bloom_animations.dart';
import 'bloom_ui.dart';

/// Product tile used by the home grid, search results and favorites.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final String heroTag;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onAdd;

  const ProductCard({
    super.key,
    required this.product,
    required this.heroTag,
    required this.onTap,
    this.isFavorite = false,
    this.onFavorite,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.quantity <= 0;

    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: AppColors.taupe.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: heroTag,
                          child: BloomImage(url: product.imageUrl),
                        ),
                      ),
                    ),

                    if (onFavorite != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: _HeartButton(
                          isFavorite: isFavorite,
                          onTap: onFavorite!,
                        ),
                      ),

                    if (outOfStock)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.forest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Sold out',
                                style: AppText.sans(
                                  size: 10.5,
                                  weight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(size: 13, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: BloomPrice(value: product.price, size: 14),
                      ),
                      if (onAdd != null)
                        _AddButton(
                          enabled: !outOfStock,
                          onTap: onAdd!,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeartButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _HeartButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border_rounded,
              key: ValueKey(isFavorite),
              size: 16,
              color: AppColors.coral,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _AddButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.forest : AppColors.line,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            Icons.add_rounded,
            size: 16,
            color: enabled ? Colors.white : AppColors.taupe,
          ),
        ),
      ),
    );
  }
}
