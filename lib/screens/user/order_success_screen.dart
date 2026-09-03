import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';

/// Confirmation screen shown right after a successful checkout.
///
/// Pops with `'orders'` or `'home'` so the shell can select the matching tab.
class OrderSuccessScreen extends StatefulWidget {
  final String orderId;

  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _pop = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.7, curve: Curves.elasticOut),
  );

  late final Animation<double> _ripple = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.15, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _reference {
    final id = widget.orderId;
    final tail = id.length <= 6 ? id : id.substring(id.length - 6);
    return '#BLOOM${tail.toUpperCase()}';
  }

  String get _deliveryWindow {
    final now = DateTime.now();
    final from = now.add(const Duration(hours: 2));
    final to = now.add(const Duration(hours: 5));
    return 'Today, ${_time(from)} – ${_time(to)}';
  }

  static String _time(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return SizedBox(
                      width: 170,
                      height: 170,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _rippleRing(0.0),
                          _rippleRing(0.25),
                          Transform.scale(
                            scale: _pop.value,
                            child: Container(
                              width: 86,
                              height: 86,
                              decoration: const BoxDecoration(
                                color: AppColors.forest,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: Text(
                    'Order Placed!',
                    style: AppText.serif(size: 27),
                  ),
                ),
                const SizedBox(height: 10),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 420),
                  child: Text.rich(
                    TextSpan(
                      text: 'Your order  ',
                      style: AppText.sans(
                        size: 13.5,
                        color: AppColors.muted,
                        height: 1.7,
                      ),
                      children: [
                        TextSpan(
                          text: _reference,
                          style: AppText.sans(
                            size: 13.5,
                            weight: FontWeight.w700,
                            color: AppColors.coral,
                          ),
                        ),
                        const TextSpan(
                          text: '\nhas been successfully placed.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 26),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Estimated Delivery',
                          style: AppText.sans(
                            size: 11.5,
                            color: AppColors.muted,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _deliveryWindow,
                          style: AppText.sans(
                            size: 14,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 38),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 580),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, 'orders'),
                      child: const Text('View Order'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 640),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, 'home'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.blush,
                        side: BorderSide.none,
                      ),
                      child: const Text('Continue Shopping'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rippleRing(double offset) {
    final value = (_ripple.value - offset).clamp(0.0, 1.0);

    return Opacity(
      opacity: (1 - value) * 0.35,
      child: Container(
        width: 86 + (84 * value),
        height: 86 + (84 * value),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.forest, width: 1.4),
        ),
      ),
    );
  }
}
