import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/order_model.dart';
import '../../services/order_service.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({
    super.key,
  });

  final OrderService _orderService =
  OrderService();

  // ============================================================
  // Order Statuses
  // ============================================================

  static const List<String> _orderStatuses = [
    'Pending',
    'Processing',
    'Out for Delivery',
    'Delivered',
  ];

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
          'Orders',
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

      body: StreamBuilder<List<OrderModel>>(
        stream:
        _orderService.getAllOrders(),

        builder:
            (context, snapshot) {
          // ====================================================
          // Error
          // ====================================================

          if (snapshot.hasError) {
            return _buildMessage(
              icon:
              Icons.error_outline_rounded,
              title:
              'Something went wrong',
              subtitle:
              'We could not load orders.',
            );
          }

          // ====================================================
          // Loading
          // ====================================================

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

          // ====================================================
          // Empty
          // ====================================================

          if (orders.isEmpty) {
            return _buildMessage(
              icon:
              Icons.receipt_long_outlined,
              title:
              'No orders yet',
              subtitle:
              'Orders from users will appear here.',
            );
          }

          // ====================================================
          // Orders List
          // ====================================================

          return ListView.separated(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              30,
            ),

            itemCount:
            orders.length,

            separatorBuilder:
                (context, index) =>
            const SizedBox(
              height: 14,
            ),

            itemBuilder:
                (context, index) {
              final order =
              orders[index];

              return _buildOrderCard(
                context,
                order,
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
          // ==================================================
          // Order Header
          // ==================================================

          Row(
            children: [
              Container(
                width: 42,
                height: 42,

                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFF4E8E5,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),

                child: const Icon(
                  Icons
                      .shopping_bag_outlined,
                  color:
                  Color(0xFFB86F7B),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      'Order',

                      style:
                      GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.w700,
                        color:
                        const Color(
                          0xFF4B3439,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      'ID: ${order.id}',

                      maxLines: 1,

                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      GoogleFonts.dmSans(
                        fontSize: 11,
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

          const SizedBox(
            height: 16,
          ),

          // ==================================================
          // Order Status
          // ==================================================

          _buildStatusDropdown(
            context,
            order,
          ),

          const SizedBox(
            height: 18,
          ),

          const Divider(),

          const SizedBox(
            height: 12,
          ),

          // ==================================================
          // Products
          // ==================================================

          Text(
            'Products',

            style:
            GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight:
              FontWeight.w700,
              color:
              const Color(0xFF4B3439),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // ==================================================
          // Product List
          // ==================================================

          ...order.items.map(
                (item) {
              return _buildProductItem(
                item,
              );
            },
          ),

          const SizedBox(
            height: 8,
          ),

          const Divider(),

          const SizedBox(
            height: 12,
          ),

          // ==================================================
          // Total
          // ==================================================

          Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

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

              Text(
                '\$${order.totalAmount.toStringAsFixed(2)}',

                style:
                GoogleFonts.dmSans(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w800,
                  color:
                  const Color(
                    0xFFB86F7B,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          // ==================================================
          // Customer Name
          // ==================================================

          _buildInfoRow(
            icon:
            Icons.person_outline,
            title:
            'Customer',
            value:
            order.userName.isEmpty
                ? 'Unknown User'
                : order.userName,
          ),

          const SizedBox(
            height: 10,
          ),

          // ==================================================
          // Customer Phone
          // ==================================================

          _buildInfoRow(
            icon:
            Icons.phone_outlined,
            title:
            'Phone',
            value:
            order.userPhone.isEmpty
                ? 'Not available'
                : order.userPhone,
          ),

          const SizedBox(
            height: 10,
          ),

          // ==================================================
          // Delivery Address
          // ==================================================

          _buildInfoRow(
            icon:
            Icons.location_on_outlined,
            title:
            'Address',
            value:
            order.address.isEmpty
                ? 'Not available'
                : order.address,
          ),

          const SizedBox(
            height: 10,
          ),

          // ==================================================
          // Order Date
          // ==================================================

          _buildInfoRow(
            icon:
            Icons.calendar_today_outlined,
            title:
            'Ordered',
            value:
            _formatDate(
              order.createdAt,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          // ==================================================
          // Cancel Order
          // ==================================================

          SizedBox(
            width:
            double.infinity,

            height: 46,

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
                Icons.cancel_outlined,
                size: 19,
              ),

              label:
              Text(
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
                  BorderRadius.circular(
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
  // Status Dropdown
  // ============================================================

  Widget _buildStatusDropdown(
      BuildContext context,
      OrderModel order,
      ) {
    final currentStatus =
    _orderStatuses.contains(
      order.status,
    )
        ? order.status
        : 'Pending';

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 4,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(0xFFFFF6F3),

        borderRadius:
        BorderRadius.circular(14),

        border:
        Border.all(
          color:
          const Color(0xFFE8D1D4),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.sync_alt_rounded,
            size: 20,
            color:
            Color(0xFFB86F7B),
          ),

          const SizedBox(
            width: 10,
          ),

          Text(
            'Status',
            style:
            GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight:
              FontWeight.w700,
              color:
              const Color(
                0xFF4B3439,
              ),
            ),
          ),

          const Spacer(),

          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value:
              currentStatus,

              items:
              _orderStatuses.map(
                    (status) {
                  return DropdownMenuItem<
                      String>(
                    value:
                    status,

                    child: Text(
                      status,
                      style:
                      GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        const Color(
                          0xFF4B3439,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),

              onChanged:
                  (newStatus) async {
                if (newStatus ==
                    null) {
                  return;
                }

                if (newStatus ==
                    currentStatus) {
                  return;
                }

                try {
                  await _orderService
                      .updateOrderStatus(
                    orderId:
                    order.id,
                    status:
                    newStatus,
                  );

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Order status changed to $newStatus.',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to update order status.',
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Product Item
  // ============================================================

  Widget _buildProductItem(
      OrderItemModel item,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
      const EdgeInsets.all(10),

      decoration:
      BoxDecoration(
        color:
        const Color(0xFFFCF8F6),

        borderRadius:
        BorderRadius.circular(15),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          // ======================================================
          // Product Image
          // ======================================================

          ClipRRect(
            borderRadius:
            BorderRadius.circular(12),

            child: SizedBox(
              width: 65,
              height: 65,

              child: item.productImage.isEmpty
                  ? _buildImagePlaceholder()
                  : Image.network(
                item.productImage,

                fit:
                BoxFit.cover,

                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return _buildImagePlaceholder();
                },
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // ======================================================
          // Product Information
          // ======================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  item.productName.isEmpty
                      ? 'Unknown Product'
                      : item.productName,

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
                  height: 6,
                ),

                Text(
                  '\$${item.productPrice.toStringAsFixed(2)}',

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
          ),

          const SizedBox(
            width: 8,
          ),

          // ======================================================
          // Quantity
          // ======================================================

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),

            decoration:
            BoxDecoration(
              color:
              const Color(0xFFEFE3E0),

              borderRadius:
              BorderRadius.circular(10),
            ),

            child: Text(
              'x${item.quantity}',

              style:
              GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight:
                FontWeight.w700,
                color:
                const Color(
                  0xFF4B3439,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Image Placeholder
  // ============================================================

  Widget _buildImagePlaceholder() {
    return Container(
      color:
      const Color(0xFFF4E8E5),

      child: const Icon(
        Icons
            .image_not_supported_outlined,

        color:
        Color(0xFFB86F7B),
      ),
    );
  }

  // ============================================================
  // Info Row
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Icon(
          icon,
          size: 18,
          color:
          const Color(0xFFB86F7B),
        ),

        const SizedBox(
          width: 9,
        ),

        Text(
          '$title: ',

          style:
          GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight:
            FontWeight.w700,
            color:
            const Color(
              0xFF4B3439,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,

            style:
            GoogleFonts.dmSans(
              fontSize: 13,
              color:
              const Color(
                0xFF7D696D,
              ),
            ),
          ),
        ),
      ],
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
          const Color(0xFFFFFAF8),

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(24),
          ),

          title: Text(
            'Cancel Order?',

            style:
            GoogleFonts.playfairDisplay(
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
            'Are you sure you want to cancel this order? The products will be returned to stock.',

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
          .cancelOrderByAdmin(
        order: order,
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
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
      DateTime? date,
      ) {
    if (date == null) {
      return 'Date unavailable';
    }

    final day =
    date.day
        .toString()
        .padLeft(
      2,
      '0',
    );

    final month =
    date.month
        .toString()
        .padLeft(
      2,
      '0',
    );

    final year =
    date.year.toString();

    final hour =
    date.hour
        .toString()
        .padLeft(
      2,
      '0',
    );

    final minute =
    date.minute
        .toString()
        .padLeft(
      2,
      '0',
    );

    return '$day/$month/$year  $hour:$minute';
  }

  // ============================================================
  // Empty / Error Message
  // ============================================================

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 70,
              color:
              const Color(0xFFB86F7B),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              title,

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.playfairDisplay(
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