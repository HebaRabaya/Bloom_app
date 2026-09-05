import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_logo.dart';
import '../../widgets/bloom_ui.dart';
import 'add_product_screen.dart';
import 'admin_main_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _productService = ProductService();
  final _orderService = OrderService();

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          '${product.name} will be removed from the shop permanently.',
          style: AppText.sans(size: 13, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(120, 44),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _productService.deleteProduct(product.id);
      if (!mounted) return;
      showBloomSnack(context, '${product.name} deleted');
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to delete this product.', isError: true);
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
        child: StreamBuilder<List<ProductModel>>(
          stream: _productService.getProducts(),
          builder: (context, productSnapshot) {
            if (productSnapshot.hasError) {
              return const BloomEmptyState(
                title: 'Something went wrong',
                message: 'We could not load the dashboard.',
                icon: Icons.error_outline_rounded,
              );
            }

            if (!productSnapshot.hasData) return const BloomLoader();

            final products = productSnapshot.data!;

            return StreamBuilder<List<OrderModel>>(
              stream: _orderService.getAllOrders(),
              builder: (context, orderSnapshot) {
                final orders = orderSnapshot.data ?? const <OrderModel>[];

                final revenue = orders.fold<double>(
                  0,
                  (sum, order) => sum + order.totalAmount,
                );

                final pending = orders
                    .where((order) => order.status == 'Pending')
                    .length;

                final lowStock = products
                    .where((product) => product.quantity <= 3)
                    .length;

                return ListView(
                  padding: EdgeInsets.fromLTRB(padding, 10, padding, 24),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    FadeSlideIn(child: _buildHeader()),
                    const SizedBox(height: 22),

                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: _buildRevenueCard(revenue, orders.length),
                    ),
                    const SizedBox(height: 14),

                    FadeSlideIn(
                      delay: const Duration(milliseconds: 140),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_florist_outlined,
                              label: 'Products',
                              value: '${products.length}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.pending_actions_outlined,
                              label: 'Pending',
                              value: '$pending',
                              accent: AppColors.amber,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.inventory_2_outlined,
                              label: 'Low stock',
                              value: '$lowStock',
                              accent: lowStock > 0
                                  ? AppColors.danger
                                  : AppColors.forest,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    FadeSlideIn(
                      delay: const Duration(milliseconds: 190),
                      child: BloomSectionHeader(
                        title: 'Your products',
                        actionLabel: 'Add new',
                        onAction: () =>
                            AdminMainScreen.of(context)?.goToTab(1),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (products.isEmpty)
                      SizedBox(
                        height: 380,
                        child: BloomEmptyState(
                          title: 'No products yet',
                          message:
                              'Add your first arrangement and it will appear '
                              'in the shop instantly.',
                          icon: Icons.local_florist_outlined,
                          actionLabel: 'Add a product',
                          onAction: () =>
                              AdminMainScreen.of(context)?.goToTab(1),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: bloomGridCount(width),
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.66,
                            ),
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return FadeSlideIn.staggered(
                            index: index,
                            child: _AdminProductCard(
                              product: product,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  BloomPageRoute(
                                    builder: (_) =>
                                        AddProductScreen(product: product),
                                  ),
                                );
                              },
                              onDelete: () => _deleteProduct(product),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: AppText.serif(size: 24),
              ),
              const SizedBox(height: 2),
              Text(
                'Everything happening in your shop today.',
                style: AppText.sans(size: 12.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const BloomMark(size: 34),
      ],
    );
  }

  Widget _buildRevenueCard(double revenue, int orderCount) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.forest,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total revenue',
                  style: AppText.sans(
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.72),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${revenue.toStringAsFixed(revenue == revenue.roundToDouble() ? 0 : 2)}',
                  style: AppText.serif(size: 30, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'from $orderCount ${orderCount == 1 ? 'order' : 'orders'}',
                  style: AppText.sans(
                    size: 12,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = AppColors.forest,
  });

  @override
  Widget build(BuildContext context) {
    return BloomCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 17, color: accent),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppText.serif(size: 22)),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sans(size: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _AdminProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AdminProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lowStock = product.quantity <= 3;

    return Container(
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
                      child: BloomImage(url: product.imageUrl),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Column(
                      children: [
                        _MiniAction(
                          icon: Icons.edit_outlined,
                          onTap: onEdit,
                        ),
                        const SizedBox(height: 6),
                        _MiniAction(
                          icon: Icons.delete_outline_rounded,
                          color: AppColors.danger,
                          onTap: onDelete,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(size: 13, weight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    BloomPrice(value: product.price, size: 13.5),
                    const Spacer(),
                    Text(
                      'Qty ${product.quantity}',
                      style: AppText.sans(
                        size: 11,
                        weight: FontWeight.w600,
                        color: lowStock ? AppColors.danger : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _MiniAction({
    required this.icon,
    required this.onTap,
    this.color = AppColors.forest,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}
