import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';

/// Home hero: Ken Burns zoom, scroll parallax, and a light sweep.
class BloomCinematicBanner extends StatefulWidget {
  final double parallax;
  final Widget child;

  const BloomCinematicBanner({
    super.key,
    required this.child,
    this.parallax = 0,
  });

  @override
  State<BloomCinematicBanner> createState() => _BloomCinematicBannerState();
}

class _BloomCinematicBannerState extends State<BloomCinematicBanner>
    with TickerProviderStateMixin {
  late final AnimationController _zoom = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9000),
  )..repeat(reverse: true);

  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat();

  @override
  void dispose() {
    _zoom.dispose();
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_zoom, _sweep]),
              builder: (context, _) {
                final scale = 1.12 + _zoom.value * 0.1;
                final sweep = Curves.easeInOut.transform(
                  ((_sweep.value - 0.12) / 0.45).clamp(0.0, 1.0),
                );

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Transform.translate(
                      offset: Offset(0, widget.parallax * 0.38),
                      child: Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          AppAssets.homeHeroBanner,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity:
                          0.38 * (1 - (sweep - 0.5).abs() * 2).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(lerpDouble(-220, 280, sweep)!, 0),
                        child: Transform.rotate(
                          angle: -0.55,
                          child: Align(
                            child: Container(
                              width: 90,
                              height: 420,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.85),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: Opacity(opacity: 0.4, child: _BannerPetals()),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.blush.withValues(alpha: 0.97),
                    AppColors.blush.withValues(alpha: 0.72),
                    AppColors.blush.withValues(alpha: 0.0),
                  ],
                  stops: const [0, 0.42, 0.78],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _BannerPetals extends StatefulWidget {
  const _BannerPetals();

  @override
  State<_BannerPetals> createState() => _BannerPetalsState();
}

class _BannerPetalsState extends State<_BannerPetals>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 10000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _BannerPetalPainter(progress: _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _BannerPetalPainter extends CustomPainter {
  final double progress;

  _BannerPetalPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()..style = PaintingStyle.fill;
    const colors = [
      AppColors.coral,
      AppColors.roseGold,
      AppColors.peach,
      AppColors.terracotta,
    ];

    for (var i = 0; i < 7; i++) {
      final seed = i * 0.37;
      final t = (progress * (0.5 + seed % 0.5) + seed) % 1.0;
      final x =
          (seed * 1.7 % 1.0) * size.width + math.sin(t * math.pi * 2) * 16;
      final y = -10 + t * (size.height + 20);
      paint.color = colors[i % colors.length].withValues(alpha: 0.22);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * math.pi * 2);
      canvas.drawPath(_petal(4.5 + i % 3), paint);
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
  bool shouldRepaint(covariant _BannerPetalPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
