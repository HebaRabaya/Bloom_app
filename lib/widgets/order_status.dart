import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Single source of truth for how order statuses look and progress.
class OrderStatusInfo {
  static const steps = <String>[
    'Pending',
    'Processing',
    'Out for Delivery',
    'Delivered',
  ];

  static const stepLabels = <String>[
    'Order Confirmed',
    'Preparing Flowers',
    'Out for Delivery',
    'Delivered',
  ];

  static const stepIcons = <IconData>[
    Icons.check_circle_outline_rounded,
    Icons.local_florist_outlined,
    Icons.local_shipping_outlined,
    Icons.home_outlined,
  ];

  /// Index of the current step, or `-1` when the status is unknown.
  static int indexOf(String status) {
    final normalized = status.trim().toLowerCase();
    for (var i = 0; i < steps.length; i++) {
      if (steps[i].toLowerCase() == normalized) return i;
    }
    return normalized.isEmpty ? 0 : -1;
  }

  static Color color(String status) {
    switch (indexOf(status)) {
      case 0:
        return AppColors.amber;
      case 1:
        return AppColors.coral;
      case 2:
        return AppColors.forest;
      case 3:
        return AppColors.success;
      default:
        return AppColors.muted;
    }
  }

  static String label(String status) {
    return status.trim().isEmpty ? 'Pending' : status.trim();
  }

  static String reference(String orderId) {
    final tail = orderId.length <= 6
        ? orderId
        : orderId.substring(orderId.length - 6);
    return '#BLOOM${tail.toUpperCase()}';
  }

  static String formatDate(DateTime? date) {
    if (date == null) return 'Date unavailable';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day} ${months[date.month - 1]} ${date.year} · '
        '$hour:$minute $period';
  }
}

class OrderStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const OrderStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = OrderStatusInfo.color(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            OrderStatusInfo.label(status),
            style: AppText.sans(
              size: compact ? 10.5 : 11.5,
              weight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
