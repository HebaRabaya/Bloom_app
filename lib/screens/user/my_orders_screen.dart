import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class MyOrdersScreen
    extends StatelessWidget {
  MyOrdersScreen({
    super.key,
  });

  final OrderService _orderService =
  OrderService();

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
          'My Orders',
          style:
          GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight:
            FontWeight.w600,
            color:
            const Color(0xFF4B3439),
          ),
        ),
      ),

      body:
      StreamBuilder<List<OrderModel>>(
        stream:
        _orderService.getMyOrders(),

        builder:
            (context, snapshot) {
          // ==================================================
          // Error
          // ==================================================

          if (snapshot.hasError) {
            return _buildMessage(
              icon:
              Icons
                  .error_outline_rounded,
              title:
              'Something went wrong',
              subtitle:
              'We could not load your orders.',
            );
          }

          // ==================================================
          // Loading
          // ==================================================

          if (!snapshot.hasData) {
            return const Center(
              child:
              CircularProgressIndicator(
                color:
                Color(0xFFB86F7B),
              ),
            );
          }

          final orders =
          snapshot.data!;

          // ==================================================
          // Empty
          // ==================================================

          if (orders.isEmpty) {
            return _buildMessage(
              icon:
              Icons
                  .receipt_long_outlined,
              title:
              'No orders yet',
              subtitle:
              'Your orders will appear here 🌷',
            );
          }

          // ==================================================
          // Orders
          // ==================================================

          return ListView.separated(
            padding:
            const EdgeInsets
                .fromLTRB(
              16,
              10,
              16,
              30,
            ),

            itemCount:
            orders.length,

            separatorBuilder:
                (_, __) =>
            const SizedBox(
              height: 14,
            ),

            itemBuilder:
                (context, index) {
              return _buildOrderCard(
                context,
                orders[index],
              );
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // Order Card
  // ============================================================

  Widget _buildOrderCard(
      BuildContext context,
      OrderModel order,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(14),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withValues(
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
          // ==================================================
          // Order Header
          // ==================================================

          Row(
            children: [
              Expanded(
                child: Text(
                  'Order #${order.id.substring(0, order.id.length > 8 ? 8 : order.id.length)}',

                  style:
                  GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                      0xFF4B3439,
                    ),
                  ),
                ),
              ),

              _buildStatusBadge(
                order.status,
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          // ==================================================
          // Products
          // ==================================================

          ...order.items.map(
                (item) =>
                _buildOrderItem(
                  item,
                ),
          ),

          const SizedBox(
            height: 10,
          ),

          const Divider(
            color:
            Color(0xFFEFE5E2),
          ),

          const SizedBox(
            height: 10,
          ),

          // ==================================================
          // Total
          // ==================================================

          Row(
            children: [
              Text(
                'Total',

                style:
                GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  const Color(
                    0xFF4B3439,
                  ),
                ),
              ),

              const Spacer(),

              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',

                style:
                GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  const Color(
                    0xFFB86F7B,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          // ==================================================
          // Address
          // ==================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Icon(
                Icons
                    .location_on_outlined,
                size: 17,
                color:
                Color(0xFF92797E),
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Text(
                  order.address
                      .isEmpty
                      ? 'Address unavailable'
                      : order.address,

                  style:
                  GoogleFonts.dmSans(
                    fontSize: 12,
                    color:
                    const Color(
                      0xFF92797E,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          // ==================================================
          // Date
          // ==================================================

          Row(
            children: [
              const Icon(
                Icons
                    .calendar_today_outlined,
                size: 16,
                color:
                Color(0xFF92797E),
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child: Text(
                  _formatDate(
                    order.createdAt,
                  ),

                  style:
                  GoogleFonts.dmSans(
                    fontSize: 12,
                    color:
                    const Color(
                      0xFF92797E,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          // ==================================================
          // Cancel
          // ==================================================

          SizedBox(
            width:
            double.infinity,

            height: 45,

            child:
            OutlinedButton.icon(
              onPressed: () {
                _confirmCancel(
                  context,
                  order,
                );
              },

              icon:
              const Icon(
                Icons
                    .cancel_outlined,
                size: 18,
              ),

              label: Text(
                'Cancel Order',

                style:
                GoogleFonts.dmSans(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              style:
              OutlinedButton
                  .styleFrom(
                foregroundColor:
                const Color(
                  0xFF9E5967,
                ),

                side:
                const BorderSide(
                  color:
                  Color(
                    0xFFE1BFC4,
                  ),
                ),

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Order Item
  // ============================================================

  Widget _buildOrderItem(
      OrderItemModel item,
      ) {
    final itemTotal =
        item.productPrice *
            item.quantity;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius:
            BorderRadius.circular(
              12,
            ),

            child: SizedBox(
              width: 65,
              height: 65,

              child: Image.network(
                item.productImage,

                fit: BoxFit.cover,

                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return Container(
                    color:
                    const Color(
                      0xFFF4E8E5,
                    ),

                    child:
                    const Icon(
                      Icons
                          .image_not_supported_outlined,
                      color:
                      Color(
                        0xFFB86F7B,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  item.productName,

                  maxLines: 2,

                  overflow:
                  TextOverflow.ellipsis,

                  style:
                  GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    const Color(
                      0xFF4B3439,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Qty: ${item.quantity}',

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

          Text(
            '\$${itemTotal.toStringAsFixed(2)}',

            style:
            GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight:
              FontWeight.w700,
              color:
              const Color(
                0xFFB86F7B,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Status Badge
  // ============================================================

  Widget _buildStatusBadge(
      String status,
      ) {
    final displayStatus =
    status.isEmpty
        ? 'Pending'
        : status;

    return Container(
      padding:
      const EdgeInsets
          .symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFFFF0D9,
        ),

        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),

      child: Text(
        displayStatus,

        style:
        GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight:
          FontWeight.w700,
          color:
          const Color(
            0xFF9A6A2F,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Confirm Cancel
  // ============================================================

  Future<void> _confirmCancel(
      BuildContext context,
      OrderModel order,
      ) async {
    final shouldCancel =
    await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor:
          const Color(
            0xFFFFFAF8,
          ),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              24,
            ),
          ),

          title: Text(
            'Cancel Order?',

            style:
            GoogleFonts
                .playfairDisplay(
              fontSize: 23,
              fontWeight:
              FontWeight.w600,
              color:
              const Color(
                0xFF4B3439,
              ),
            ),
          ),

          content: Text(
            'Are you sure you want to cancel this order? The ordered quantities will be returned to stock.',

            style:
            GoogleFonts.dmSans(
              color:
              const Color(
                0xFF7D696D,
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
              const Text(
                'Keep Order',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                const Color(
                  0xFFB86F7B,
                ),

                foregroundColor:
                Colors.white,
              ),

              child:
              const Text(
                'Cancel Order',
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    try {
      await _orderService
          .cancelOrder(
        order: order,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Order cancelled successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to cancel order.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // Format Date
  // ============================================================

  String _formatDate(
      dynamic timestamp,
      ) {
    if (timestamp == null) {
      return 'Date unavailable';
    }

    try {
      final date =
      timestamp.toDate();

      final day =
      date.day
          .toString()
          .padLeft(2, '0');

      final month =
      date.month
          .toString()
          .padLeft(2, '0');

      final year =
      date.year.toString();

      final hour =
      date.hour
          .toString()
          .padLeft(2, '0');

      final minute =
      date.minute
          .toString()
          .padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return 'Date unavailable';
    }
  }

  // ============================================================
  // Empty / Error
  // ============================================================

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment
              .center,

          children: [
            Icon(
              icon,
              size: 70,
              color:
              const Color(
                0xFFB86F7B,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              title,

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts
                  .playfairDisplay(
                fontSize: 22,
                fontWeight:
                FontWeight.w600,
                color:
                const Color(
                  0xFF4B3439,
                ),
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              subtitle,

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.dmSans(
                fontSize: 13,
                color:
                const Color(
                  0xFF92797E,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}