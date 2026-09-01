import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import 'add_product_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({
    super.key,
  });

  @override
  State<AdminHomeScreen> createState() =>
      _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final ProductService _productService =
  ProductService();

  final OrderService _orderService =
  OrderService();

  // ============================================================
  // Delete Product
  // ============================================================

  Future<void> _deleteProduct(
      ProductModel product,
      ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Product?',
          ),
          content: Text(
            'Are you sure you want to delete ${product.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _productService.deleteProduct(
      product.id,
    );
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
          'Admin Dashboard',
          style:
          GoogleFonts.playfairDisplay(
            fontSize: 25,
            fontWeight:
            FontWeight.w600,
            color:
            const Color(0xFF4B3439),
          ),
        ),
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream:
        _productService.getProducts(),

        builder:
            (context, productSnapshot) {
          if (productSnapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong.',
              ),
            );
          }

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

          return StreamBuilder<List<OrderModel>>(
            stream:
            _orderService.getAllOrders(),

            builder:
                (context, orderSnapshot) {
              if (orderSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'Something went wrong.',
                  ),
                );
              }

              if (!orderSnapshot.hasData) {
                return const Center(
                  child:
                  CircularProgressIndicator(
                    color:
                    Color(0xFFB86F7B),
                  ),
                );
              }

              final orders =
              orderSnapshot.data!;

              return ListView(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  30,
                ),

                children: [
                  // ==================================================
                  // Dashboard Statistics
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon:
                          Icons.receipt_long_outlined,
                          title:
                          'Total Orders',
                          value:
                          orders.length.toString(),
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: _buildStatCard(
                          icon:
                          Icons.local_florist_outlined,
                          title:
                          'Total Products',
                          value:
                          products.length.toString(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // Products Title
                  // ==================================================

                  Text(
                    'Products',
                    style:
                    GoogleFonts.playfairDisplay(
                      fontSize: 23,
                      fontWeight:
                      FontWeight.w600,
                      color:
                      const Color(0xFF4B3439),
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    'Manage your store products.',
                    style:
                    GoogleFonts.dmSans(
                      fontSize: 13,
                      color:
                      const Color(0xFF92797E),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ==================================================
                  // Products
                  // ==================================================

                  if (products.isEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 80,
                      ),
                      child: Center(
                        child: Text(
                          'No products yet 🌷',
                          style:
                          GoogleFonts.dmSans(
                            fontSize: 16,
                            color:
                            const Color(
                              0xFF92797E,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),

                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.60,
                      ),

                      itemCount:
                      products.length,

                      itemBuilder:
                          (context, index) {
                        final product =
                        products[index];

                        return _buildProductCard(
                          product,
                        );
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // Statistics Card
  // ============================================================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding:
      const EdgeInsets.all(18),

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

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Container(
            width: 44,
            height: 44,

            decoration:
            BoxDecoration(
              color:
              const Color(0xFFF4E8E5),
              borderRadius:
              BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color:
              const Color(0xFFB86F7B),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            title,
            style:
            GoogleFonts.dmSans(
              fontSize: 12,
              color:
              const Color(0xFF92797E),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            value,
            style:
            GoogleFonts.dmSans(
              fontSize: 25,
              fontWeight:
              FontWeight.w800,
              color:
              const Color(0xFF4B3439),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Product Card
  // ============================================================

  Widget _buildProductCard(
      ProductModel product,
      ) {
    return Container(
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: 0.05,
            ),
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
              // Product Image
              // ==================================================

              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(
                  top:
                  Radius.circular(20),
                ),

                child: SizedBox(
                  height: 130,
                  width:
                  double.infinity,

                  child:
                  Image.network(
                    product.imageUrl,
                    fit:
                    BoxFit.cover,

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
                        ),
                      );
                    },
                  ),
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.all(12),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      product.name,

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      GoogleFonts.dmSans(
                        fontWeight:
                        FontWeight.w700,
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
                          0xFFB86F7B,
                        ),
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      'Qty: ${product.quantity}',

                      style:
                      GoogleFonts.dmSans(
                        fontSize: 12,
                        color:
                        const Color(
                          0xFF92797E,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ====================================================
          // Edit
          // ====================================================

          Positioned(
            top: 8,
            right: 45,

            child: CircleAvatar(
              radius: 16,
              backgroundColor:
              Colors.white,

              child: IconButton(
                iconSize: 17,

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddProductScreen(
                            product:
                            product,
                          ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.edit_outlined,
                ),
              ),
            ),
          ),

          // ====================================================
          // Delete
          // ====================================================

          Positioned(
            top: 8,
            right: 8,

            child: CircleAvatar(
              radius: 16,
              backgroundColor:
              Colors.white,

              child: IconButton(
                iconSize: 17,

                onPressed: () {
                  _deleteProduct(
                    product,
                  );
                },

                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}