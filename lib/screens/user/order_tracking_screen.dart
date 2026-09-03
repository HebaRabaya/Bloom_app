import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';
import '../../widgets/order_status.dart';

/// Live order detail with a progress timeline driven by the Firestore status.
class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _orderService = OrderService();

  bool _isCancelling = false;

  Future<void> _confirmCancel(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: Text(
          'The reserved quantities will be returned to stock and the order '
          'will be removed.',
          style: AppText.sans(size: 13, color: AppColors.muted, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep order'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              minimumSize: const Size(130, 44),
            ),
            child: const Text('Cancel order'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);

    try {
      await _orderService.cancelOrder(order: order);
      if (!mounted) return;
      showBloomSnack(context, 'Your order has been cancelled');
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(context, 'Unable to cancel this order.', isError: true);
    } finally {
      if (mounted) setState(() => _isCancelling = false);
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
        title: const Text('Track Order'),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderService.getMyOrders(),
        builder: (context, snapshot) {
          // Fall back to the order we were opened with until the stream warms
          // up, so the screen never flashes empty.
          var order = widget.order;

          if (snapshot.hasData) {
            final match = snapshot.data!
                .where((item) => item.id == widget.order.id)
                .toList();

            if (match.isEmpty && !_isCancelling) {
              return const BloomEmptyState(
                title: 'Order not available',
                message: 'This order is no longer in your list.',
                icon: Icons.receipt_long_outlined,
              );
            }

            if (match.isNotEmpty) order = match.first;
          }

          final stepIndex = OrderStatusInfo.indexOf(order.status);
          final canCancel = stepIndex < 3;

          return ListView(
            padding: EdgeInsets.fromLTRB(padding, 6, padding, 40),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              FadeSlideIn(child: _buildHeaderCard(order)),
              const SizedBox(height: 18),
              FadeSlideIn(
                delay: const Duration(milliseconds: 90),
                child: _buildTimeline(stepIndex),
              ),
              const SizedBox(height: 18),
              FadeSlideIn(
                delay: const Duration(milliseconds: 150),
                child: _buildItems(order),
              ),
              const SizedBox(height: 18),
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: _buildAddress(order),
              ),
              if (canCancel) ...[
                const SizedBox(height: 22),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 250),
                  child: OutlinedButton.icon(
                    onPressed: _isCancelling
                        ? null
                        : () => _confirmCancel(order),
                    icon: const Icon(Icons.close_rounded, size: 17),
                    label: Text(
                      _isCancelling ? 'Cancelling…' : 'Cancel Order',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // Sections
  // ============================================================

  Widget _buildHeaderCard(OrderModel order) {
    return BloomCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  OrderStatusInfo.reference(order.id),
                  style: AppText.serif(size: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  OrderStatusInfo.formatDate(order.createdAt),
                  style: AppText.sans(size: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }

  Widget _buildTimeline(int stepIndex) {
    return BloomCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < OrderStatusInfo.stepLabels.length; i++)
            _TimelineStep(
              label: OrderStatusInfo.stepLabels[i],
              icon: OrderStatusInfo.stepIcons[i],
              done: stepIndex >= i && stepIndex >= 0,
              active: stepIndex == i,
              isLast: i == OrderStatusInfo.stepLabels.length - 1,
              delay: Duration(milliseconds: 120 * i),
            ),
        ],
      ),
    );
  }

  Widget _buildItems(OrderModel order) {
    return BloomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Items', style: AppText.serif(size: 18)),
          const SizedBox(height: 14),
          for (final item in order.items) ...[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: BloomImage(url: item.productImage),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(
                          size: 13,
                          weight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Qty ${item.quantity}',
                        style: AppText.sans(
                          size: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                BloomPrice(
                  value: item.productPrice * item.quantity,
                  size: 13.5,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.line),
            ),
          ],
          Row(
            children: [
              Text(
                'Total',
                style: AppText.sans(size: 14.5, weight: FontWeight.w600),
              ),
              const Spacer(),
              BloomPrice(value: order.totalAmount, size: 19),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(OrderModel order) {
    return BloomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.blush,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 19,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery address',
                  style: AppText.sans(size: 11.5, color: AppColors.muted),
                ),
                const SizedBox(height: 3),
                Text(
                  order.address.isEmpty
                      ? 'Address unavailable'
                      : order.address,
                  style: AppText.sans(size: 13, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool done;
  final bool active;
  final bool isLast;
  final Duration delay;

  const _TimelineStep({
    required this.label,
    required this.icon,
    required this.done,
    required this.active,
    required this.isLast,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.forest : AppColors.line;

    return FadeSlideIn(
      delay: delay,
      offsetY: 0,
      offsetX: -18,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: done ? AppColors.forest : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.6),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppColors.forest.withValues(alpha: 0.25),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    done ? Icons.check_rounded : icon,
                    size: 16,
                    color: done ? Colors.white : AppColors.taupe,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: done ? AppColors.forest : AppColors.line,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 7, bottom: isLast ? 12 : 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppText.sans(
                        size: 13.5,
                        weight: active ? FontWeight.w700 : FontWeight.w500,
                        color: done ? AppColors.ink : AppColors.muted,
                      ),
                    ),
                    if (active)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'In progress',
                          style: AppText.sans(
                            size: 11,
                            color: AppColors.coral,
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
    );
  }
}
