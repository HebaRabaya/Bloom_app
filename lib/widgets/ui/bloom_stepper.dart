import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Quantity stepper shared by the product page and the cart.
class BloomQuantityStepper extends StatefulWidget {
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final bool compact;

  const BloomQuantityStepper({
    super.key,
    required this.quantity,
    this.onIncrease,
    this.onDecrease,
    this.compact = false,
  });

  @override
  State<BloomQuantityStepper> createState() => _BloomQuantityStepperState();
}

class _BloomQuantityStepperState extends State<BloomQuantityStepper> {
  bool _goingUp = true;

  @override
  void didUpdateWidget(covariant BloomQuantityStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity) {
      _goingUp = widget.quantity > oldWidget.quantity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 28.0 : 34.0;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.creamDeep,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.remove_rounded, widget.onDecrease, size),
          Container(
            constraints: BoxConstraints(minWidth: size),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) {
                final offset = Offset(0, _goingUp ? 0.45 : -0.45);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: offset,
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                '${widget.quantity}',
                key: ValueKey(widget.quantity),
                style: AppText.sans(
                  size: widget.compact ? 13 : 14.5,
                  weight: FontWeight.w600,
                ),
              ),
            ),
          ),
          _button(Icons.add_rounded, widget.onIncrease, size),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback? onTap, double size) {
    final enabled = onTap != null;

    return Material(
      color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.52,
            color: enabled ? AppColors.forest : AppColors.taupe,
          ),
        ),
      ),
    );
  }
}
