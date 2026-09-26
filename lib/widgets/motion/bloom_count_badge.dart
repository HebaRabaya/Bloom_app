import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Cart-tab badge that pops whenever the count increases.
class BloomCountBadge extends StatefulWidget {
  final int count;

  const BloomCountBadge({super.key, required this.count});

  @override
  State<BloomCountBadge> createState() => _BloomCountBadgeState();
}

class _BloomCountBadgeState extends State<BloomCountBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );

  @override
  void didUpdateWidget(covariant BloomCountBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count > oldWidget.count && widget.count > 0) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count <= 0) return const SizedBox.shrink();

    final scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.38), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.38, end: 1), weight: 60),
    ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOutBack));

    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        return Transform.scale(scale: scale.value, child: child);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        constraints: const BoxConstraints(minWidth: 16),
        decoration: BoxDecoration(
          color: AppColors.coral,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Text(
          widget.count > 9 ? '9+' : '${widget.count}',
          textAlign: TextAlign.center,
          style: AppText.sans(
            size: 9,
            weight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
