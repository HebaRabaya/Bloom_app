import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../bloom_wow.dart';

/// Circular + button that bounces and morphs into a check when tapped.
class BloomCartAddButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onTap;
  final double size;
  final String? flightImageUrl;

  const BloomCartAddButton({
    super.key,
    required this.enabled,
    required this.onTap,
    this.size = 28,
    this.flightImageUrl,
  });

  @override
  State<BloomCartAddButton> createState() => _BloomCartAddButtonState();
}

class _BloomCartAddButtonState extends State<BloomCartAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  bool _success = false;

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) return;
    HapticFeedback.lightImpact();
    widget.onTap();
    BloomCartFlight.launch(context, imageUrl: widget.flightImageUrl);
    setState(() => _success = true);
    _pop.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() => _success = false);
      _pop.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1, end: 0.78), weight: 18),
      TweenSequenceItem(tween: Tween(begin: 0.78, end: 1.18), weight: 42),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 1), weight: 40),
    ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));

    final color = !widget.enabled
        ? AppColors.line
        : _success
        ? AppColors.success
        : AppColors.forest;

    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        return Transform.scale(scale: _success ? scale.value : 1, child: child);
      },
      child: Material(
        color: color,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.enabled ? _handleTap : null,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                _success ? Icons.check_rounded : Icons.add_rounded,
                key: ValueKey(_success),
                size: widget.size * 0.58,
                color: widget.enabled ? Colors.white : AppColors.taupe,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Heart button with an elastic pop and a small burst of petals when saved.
class BloomHeartButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;
  final Color background;

  const BloomHeartButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 30,
    this.background = Colors.white,
  });

  @override
  State<BloomHeartButton> createState() => _BloomHeartButtonState();
}

class _BloomHeartButtonState extends State<BloomHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 560),
  );

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    if (!widget.isFavorite) {
      _burst.forward(from: 0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            child: OverflowBox(
              maxWidth: widget.size + 28,
              maxHeight: widget.size + 28,
              child: AnimatedBuilder(
                animation: _burst,
                builder: (context, _) {
                  return CustomPaint(
                    size: Size(widget.size + 28, widget.size + 28),
                    painter: _HeartBurstPainter(progress: _burst.value),
                  );
                },
              ),
            ),
          ),
          Material(
            color: widget.background.withValues(alpha: 0.92),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _handleTap,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey(widget.isFavorite),
                  tween: Tween(begin: 0.72, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border_rounded,
                      key: ValueKey(widget.isFavorite),
                      size: widget.size * 0.52,
                      color: AppColors.coral,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeartBurstPainter extends CustomPainter {
  final double progress;

  _HeartBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;
    final curve = Curves.easeOutCubic.transform(progress);
    final fade = (1 - progress).clamp(0.0, 1.0);

    for (var i = 0; i < 7; i++) {
      final angle = -math.pi / 2 + (i * 2 * math.pi / 7);
      final distance = 10 + curve * 16;
      final origin = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      paint.color = (i.isEven ? AppColors.coral : AppColors.roseGold)
          .withValues(alpha: fade * 0.9);

      canvas.save();
      canvas.translate(origin.dx, origin.dy);
      canvas.rotate(angle + progress);
      canvas.drawPath(_dotPetal(3.4 + (1 - progress) * 1.6), paint);
      canvas.restore();
    }
  }

  Path _dotPetal(double size) {
    return Path()
      ..moveTo(0, -size)
      ..cubicTo(size * 0.7, -size * 0.3, size * 0.5, size * 0.4, 0, size)
      ..cubicTo(-size * 0.5, size * 0.4, -size * 0.7, -size * 0.3, 0, -size)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _HeartBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
