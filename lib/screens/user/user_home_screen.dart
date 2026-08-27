import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/product_model.dart';
import '../../services/favorite_service.dart';
import '../../services/product_service.dart';
import 'product_details_screen.dart';

class UserHomeScreen extends StatelessWidget {
  UserHomeScreen({super.key});

  final ProductService _productService =
  ProductService();

  final FavoriteService _favoriteService =
  FavoriteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF9F4F1),

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,
        elevation: 0,

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Bloom Shop',
              style:
              GoogleFonts.playfairDisplay(
                fontSize: 25,
                fontWeight:
                FontWeight.w600,
                color:
                const Color(0xFF4B3439),
              ),
            ),

            Text(
              'Find something beautiful for you 🌷',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color:
                const Color(0xFF92797E),
              ),
            ),
          ],
        ),
      ),

      body: StreamBuilder<
          List<ProductModel>>(
        stream:
        _productService.getProducts(),

        builder:
            (context, productSnapshot) {
          // ==================================================
          // Product Error
          // ==================================================

          if (productSnapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong.',
                style:
                GoogleFonts.dmSans(),
              ),
            );
          }

          // ==================================================
          // Product Loading
          // ==================================================

          if (!productSnapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(
                color:
                Color(0xFFB86F7B),
              ),
            );
          }

          final products =
          productSnapshot.data!;

          // ==================================================
          // Empty
          // ==================================================

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons
                        .local_florist_outlined,
                    size: 70,
                    color:
                    Color(0xFFB86F7B),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Text(
                    'No products available yet',
                    style: GoogleFonts
                        .playfairDisplay(
                      fontSize: 21,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      const Color(
                          0xFF4B3439),
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Come back soon 🌷',
                    style:
                    GoogleFonts.dmSans(
                      color:
                      const Color(
                          0xFF92797E),
                    ),
                  ),
                ],
              ),
            );
          }

          // ==================================================
          // Favorite IDs
          // ==================================================

          return StreamBuilder<
              Set<String>>(
            stream:
            _favoriteService
                .getFavoriteProductIds(),

            builder:
                (context, favoriteSnapshot) {
              final favoriteIds =
                  favoriteSnapshot.data ??
                      <String>{};

              return GridView.builder(
                padding:
                const EdgeInsets.all(
                    16),

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.58,
                ),

                itemCount:
                products.length,

                itemBuilder:
                    (context, index) {
                  final product =
                  products[index];

                  return _buildProductCard(
                    context,
                    product,
                    favoriteIds.contains(
                        product.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // Product Card
  // ============================================================

  Widget _buildProductCard(
      BuildContext context,
      ProductModel product,
      bool isFavorite,
      ) {
    final isOutOfStock =
        product.quantity <= 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(
                  product: product,
                ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.05),
              blurRadius: 15,
              offset:
              const Offset(0, 5),
            ),
          ],
        ),

        child: Stack(
          children: [
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ==================================================
                // Image
                // ==================================================

                ClipRRect(
                  borderRadius:
                  const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),

                  child: SizedBox(
                    height: 150,
                    width: double.infinity,

                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,

                      errorBuilder:
                          (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Center(
                          child: Icon(
                            Icons
                                .image_not_supported_outlined,
                            size: 40,
                            color: Color(
                                0xFFB86F7B),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ==================================================
                // Product Info
                // ==================================================

                Padding(
                  padding:
                  const EdgeInsets.all(
                      12),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        style:
                        GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w700,
                          color:
                          const Color(
                              0xFF4B3439),
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                      Text(
                        '\$${product.price}',
                        style:
                        GoogleFonts.dmSans(
                          color:
                          const Color(
                              0xFFB86F7B),
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          isOutOfStock
                              ? const Color(
                              0xFFF4DEDE)
                              : const Color(
                              0xFFE8F1E6),
                          borderRadius:
                          BorderRadius
                              .circular(20),
                        ),

                        child: Text(
                          isOutOfStock
                              ? 'Out of Stock'
                              : '${product.quantity} available',

                          style:
                          GoogleFonts.dmSans(
                            fontSize: 11,
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
              ],
            ),

            // ==================================================
            // Favorite Button
            // ==================================================

            Positioned(
              top: 10,
              right: 10,

              child: Container(
                decoration:
                const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),

                child: IconButton(
                  onPressed: () async {
                    try {
                      await _favoriteService
                          .toggleFavorite(
                        product,
                      );
                    } catch (e) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                          context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Unable to update favorites.',
                          ),
                        ),
                      );
                    }
                  },

                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,

                    color:
                    const Color(
                        0xFFB86F7B),
                  ),
                ),
              ),
            ),

            // ==================================================
            // Out Of Stock Overlay
            // ==================================================

            if (isOutOfStock)
              Positioned.fill(
                child: Container(
                  decoration:
                  BoxDecoration(
                    color: Colors.black
                        .withValues(
                      alpha: 0.35,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                        20),
                  ),

                  alignment:
                  Alignment.center,

                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration:
                    BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                          20),
                    ),

                    child: Text(
                      'Out of Stock',
                      style:
                      GoogleFonts.dmSans(
                        fontWeight:
                        FontWeight.w700,
                        color: Colors.red,
                      ),
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