import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

/// Instagram-style heart that explodes over a photo on double-tap.
class BloomDoubleTapLike extends StatefulWidget {
  final Widget child;
  final VoidCallback? onLike;

  const BloomDoubleTapLike({super.key, required this.child, this.onLike});

  @override
  State<BloomDoubleTapLike> createState() => _BloomDoubleTapLikeState();
}

class _BloomDoubleTapLikeState extends State<BloomDoubleTapLike>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  late final Animation<double> _pop = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.45, curve: Curves.elasticOut),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.55, 1, curve: Curves.easeIn),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    HapticFeedback.mediumImpact();
    widget.onLike?.call();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _play,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.value == 0) return const SizedBox.shrink();

              final opacity = (1 - _fade.value).clamp(0.0, 1.0);
              return IgnorePointer(
                child: Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: _pop.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(160, 160),
                          painter: _LikeBurstPainter(
                            progress: _controller.value,
                          ),
                        ),
                        Icon(
                          Icons.favorite,
                          size: 92,
                          color: Colors.white.withValues(alpha: 0.96),
                          shadows: [
                            BoxShadow(
                              color: AppColors.coral.withValues(alpha: 0.7),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LikeBurstPainter extends CustomPainter {
  final double progress;

  _LikeBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final fade = (1 - progress).clamp(0.0, 1.0);
    final origin = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 12; i++) {
      final angle = i * (2 * math.pi / 12);
      final distance = 18 + t * 52;
      final center = Offset(
        origin.dx + math.cos(angle) * distance,
        origin.dy + math.sin(angle) * distance,
      );
      paint.color = (i.isEven ? AppColors.coral : AppColors.peach).withValues(
        alpha: fade * 0.9,
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + t * 2);
      canvas.drawPath(_petal(i.isEven ? 8 : 5.5), paint);
      canvas.restore();
    }
  }

  Path _petal(double size) {
    return Path()
      ..moveTo(0, -size)
      ..cubicTo(size * 0.7, -size * 0.3, size * 0.5, size * 0.4, 0, size)
      ..cubicTo(-size * 0.5, size * 0.4, -size * 0.7, -size * 0.3, 0, -size)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _LikeBurstPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
