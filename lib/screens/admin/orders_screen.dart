import 'package:flutter/material.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_ui.dart';
import '../../widgets/order_status.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _orderService = OrderService();

  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final padding = bloomPagePadding(MediaQuery.sizeOf(context).width);
    final filters = ['All', ...OrderStatusInfo.steps];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 16, padding, 0),
              child: FadeSlideIn(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Orders', style: AppText.serif(size: 24)),
                    const SizedBox(height: 2),
                    Text(
                      'Track and update every customer order.',
                      style: AppText.sans(
                        size: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(
              height: 62,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(padding, 14, padding, 10),
                itemCount: filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 9),
                itemBuilder: (context, index) {
                  final value = filters[index];
                  return BloomChip(
                    label: value,
                    selected: value == _filter,
                    onTap: () => setState(() => _filter = value),
                  );
                },
              ),
            ),

            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: _orderService.getAllOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const BloomEmptyState(
                      title: 'Something went wrong',
                      message: 'We could not load the orders.',
                      icon: Icons.error_outline_rounded,
                    );
                  }

                  if (!snapshot.hasData) return const BloomLoader();

                  final all = snapshot.data!;
                  final orders = _filter == 'All'
                      ? all
                      : all
                            .where(
                              (order) =>
                                  OrderStatusInfo.label(order.status) ==
                                  _filter,
                            )
                            .toList();

                  if (orders.isEmpty) {
                    return BloomEmptyState(
                      title: all.isEmpty
                          ? 'No orders yet'
                          : 'Nothing in "$_filter"',
                      message: all.isEmpty
                          ? 'New customer orders will land here in real time.'
                          : 'Try another status filter to see more orders.',
                      icon: Icons.receipt_long_outlined,
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(padding, 2, padding, 24),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return FadeSlideIn.staggered(
                        key: ValueKey(orders[index].id),
                        index: index,
                        child: _AdminOrderCard(
                          order: orders[index],
                          orderService: _orderService,
                        ),
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

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderService orderService;

  const _AdminOrderCard({required this.order, required this.orderService});

  @override
  Widget build(BuildContext context) {
    return BloomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      OrderStatusInfo.reference(order.id),
                      style: AppText.sans(size: 13.5, weight: FontWeight.w700),
                    ),
                    Text(
                      OrderStatusInfo.formatDate(order.createdAt),
                      style: AppText.sans(
                        size: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(status: order.status, compact: true),
            ],
          ),
          const SizedBox(height: 14),

          _infoRow(
            Icons.person_outline_rounded,
            order.userName.isEmpty ? 'Customer' : order.userName,
          ),
          if (order.userPhone.isNotEmpty) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.phone_outlined, order.userPhone),
          ],
          const SizedBox(height: 6),
          _infoRow(
            Icons.location_on_outlined,
            order.address.isEmpty ? 'Address unavailable' : order.address,
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: AppColors.line),
          ),

          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 46,
                      height: 46,
                      child: BloomImage(url: item.productImage),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sans(
                            size: 12.5,
                            weight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Qty ${item.quantity}',
                          style: AppText.sans(
                            size: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BloomPrice(
                    value: item.productPrice * item.quantity,
                    size: 12.5,
                  ),
                ],
              ),
            ),

          Row(
            children: [
              Text(
                'Total',
                style: AppText.sans(size: 14, weight: FontWeight.w600),
              ),
              const Spacer(),
              BloomPrice(value: order.totalAmount, size: 18),
            ],
          ),
          const SizedBox(height: 16),

          _buildStatusPicker(context),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmCancel(context),
              icon: const Icon(Icons.close_rounded, size: 17),
              label: const Text('Cancel & restock'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                minimumSize: const Size.fromHeight(46),
                side: BorderSide(
                  color: AppColors.danger.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPicker(BuildContext context) {
    final current = OrderStatusInfo.steps.contains(order.status)
        ? order.status
        : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.creamDeep,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.autorenew_rounded,
            size: 17,
            color: AppColors.forest,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: current,
                isExpanded: true,
                borderRadius: BorderRadius.circular(18),
                dropdownColor: Colors.white,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.forest,
                ),
                style: AppText.sans(size: 13, weight: FontWeight.w600),
                items: [
                  for (final status in OrderStatusInfo.steps)
                    DropdownMenuItem(value: status, child: Text(status)),
                ],
                onChanged: (value) {
                  if (value == null || value == current) return;
                  _updateStatus(context, value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppText.sans(size: 12, color: AppColors.muted, height: 1.5),
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    try {
      await orderService.updateOrderStatus(orderId: order.id, status: status);
      if (!context.mounted) return;
      showBloomSnack(context, 'Order marked as "$status"');
    } catch (_) {
      if (!context.mounted) return;
      showBloomSnack(context, 'Unable to update the status.', isError: true);
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: Text(
          'The order will be deleted and all quantities returned to stock.',
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
    if (!context.mounted) return;

    try {
      await orderService.cancelOrderByAdmin(order: order);
      if (!context.mounted) return;
      showBloomSnack(context, 'Order cancelled and stock restored');
    } catch (_) {
      if (!context.mounted) return;
      showBloomSnack(context, 'Unable to cancel this order.', isError: true);
    }
  }
}
