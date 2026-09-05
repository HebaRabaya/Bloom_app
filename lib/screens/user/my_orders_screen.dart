import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';
import '../../widgets/order_status.dart';
import 'order_tracking_screen.dart';
import 'user_main_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService();
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 14, padding, 6),
              child: Text('My Orders', style: AppText.serif(size: 22)),
            ),
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: orderService.getMyOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const BloomEmptyState(
                      title: 'Something went wrong',
                      message: 'We could not load your orders right now.',
                      icon: Icons.error_outline_rounded,
                    );
                  }

                  if (!snapshot.hasData) return const BloomLoader();

                  final orders = snapshot.data!;

                  if (orders.isEmpty) {
                    return BloomEmptyState(
                      title: 'No orders yet',
                      message:
                          'Once you place an order you can follow every step '
                          'of its journey here.',
                      icon: Icons.receipt_long_outlined,
                      actionLabel: 'Browse flowers',
                      onAction: () => UserMainScreen.of(context)?.goToTab(0),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(padding, 10, padding, 24),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return FadeSlideIn.staggered(
                        index: index,
                        child: _OrderCard(order: orders[index]),
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
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final preview = order.items.take(3).toList();
    final extra = order.items.length - preview.length;

    return BloomCard(
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          BloomPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  OrderStatusInfo.reference(order.id),
                  style: AppText.sans(size: 13.5, weight: FontWeight.w700),
                ),
              ),
              OrderStatusBadge(status: order.status, compact: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            OrderStatusInfo.formatDate(order.createdAt),
            style: AppText.sans(size: 11.5, color: AppColors.muted),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              for (final item in preview) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: BloomImage(url: item.productImage),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (extra > 0)
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.creamDeep,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '+$extra',
                    style: AppText.sans(size: 12, weight: FontWeight.w600),
                  ),
                ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.totalQuantity} items',
                    style: AppText.sans(size: 11.5, color: AppColors.muted),
                  ),
                  BloomPrice(value: order.totalAmount, size: 17),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.muted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.address.isEmpty
                      ? 'Address unavailable'
                      : order.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(size: 11.5, color: AppColors.muted),
                ),
              ),
              Text(
                'Track',
                style: AppText.sans(
                  size: 12,
                  weight: FontWeight.w600,
                  color: AppColors.coral,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: AppColors.coral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
