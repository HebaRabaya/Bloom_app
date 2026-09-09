import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';

/// Flies a miniature bouquet from the tapped control to the cart tab.
class BloomCartFlight {
  static final cartIconKey = GlobalKey();
  static final arrivalTick = ValueNotifier<int>(0);

  static void launch(BuildContext context, {String? imageUrl}) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final startBox = context.findRenderObject();
    if (startBox is! RenderBox || !startBox.hasSize) return;
    final start = startBox.localToGlobal(startBox.size.center(Offset.zero));

    Offset end;
    final endBox = cartIconKey.currentContext?.findRenderObject();
    if (endBox is RenderBox && endBox.hasSize) {
      end = endBox.localToGlobal(endBox.size.center(Offset.zero));
    } else {
      final size = MediaQuery.sizeOf(context);
      end = Offset(size.width * 0.5, size.height - 34);
    }

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _CartFlightLayer(
        start: start,
        end: end,
        imageUrl: imageUrl,
        onCompleted: () {
          entry.remove();
          arrivalTick.value++;
          HapticFeedback.mediumImpact();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _CartFlightLayer extends StatefulWidget {
  final Offset start;
  final Offset end;
  final String? imageUrl;
  final VoidCallback onCompleted;

  const _CartFlightLayer({
    required this.start,
    required this.end,
    required this.imageUrl,
    required this.onCompleted,
  });

  @override
  State<_CartFlightLayer> createState() => _CartFlightLayerState();
}

class _CartFlightLayerState extends State<_CartFlightLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 820),
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward().whenComplete(widget.onCompleted);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _point(double t) {
    final control = Offset(
      (widget.start.dx + widget.end.dx) / 2,
      math.min(widget.start.dy, widget.end.dy) - 160,
    );
    return Offset(
      _quad(widget.start.dx, control.dx, widget.end.dx, t),
      _quad(widget.start.dy, control.dy, widget.end.dy, t),
    );
  }

  double _quad(double a, double b, double c, double t) {
    final mt = 1 - t;
    return mt * mt * a + 2 * mt * t * b + t * t * c;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, _) {
          final t = _curve.value;
          return Stack(
            children: [
              CustomPaint(
                painter: _FlightBurstPainter(origin: widget.start, progress: t),
                child: const SizedBox.expand(),
              ),
              for (final trail in [0.0, 0.1, 0.2])
                if (t - trail > 0)
                  _flightToken(
                    _point((t - trail).clamp(0.0, 1.0)),
                    t,
                    1 - trail * 3,
                    trail == 0,
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _flightToken(Offset point, double t, double fade, bool primary) {
    final size = primary ? lerpDouble(46, 22, t)! : 16.0;
    final opacity = (fade * (1 - t * 0.15)).clamp(0.0, 1.0);

    return Positioned(
      left: point.dx - size / 2,
      top: point.dy - size / 2,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: t * 1.2,
          child: Transform.scale(
            scale: primary ? lerpDouble(1.05, 0.55, t)! : 0.7,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.coral.withValues(alpha: 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: primary ? _payload() : _petalDot(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _payload() {
    final url = widget.imageUrl?.trim() ?? '';
    if (url.isEmpty) return _petalDot();

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _petalDot(),
    );
  }

  Widget _petalDot() {
    return const ColoredBox(
      color: AppColors.blush,
      child: Icon(
        Icons.local_florist_rounded,
        color: AppColors.coral,
        size: 18,
      ),
    );
  }
}

class _FlightBurstPainter extends CustomPainter {
  final Offset origin;
  final double progress;

  _FlightBurstPainter({required this.origin, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress > 0.45) return;

    final t = Curves.easeOut.transform((progress / 0.45).clamp(0.0, 1.0));
    final fade = (1 - progress / 0.45).clamp(0.0, 1.0);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 8; i++) {
      final angle = -math.pi / 2 + i * math.pi / 4;
      final distance = 8 + t * 36;
      final center = Offset(
        origin.dx + math.cos(angle) * distance,
        origin.dy + math.sin(angle) * distance,
      );
      paint.color = (i.isEven ? AppColors.coral : AppColors.roseGold)
          .withValues(alpha: fade * 0.85);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle + t);
      canvas.drawPath(_petal(5.5), paint);
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
  bool shouldRepaint(covariant _FlightBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.origin != origin;
  }
}

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

/// Full-screen exploding petals used on the order-success screen.
class BloomCelebration extends StatefulWidget {
  const BloomCelebration({super.key});

  @override
  State<BloomCelebration> createState() => _BloomCelebrationState();
}

class _BloomCelebrationState extends State<BloomCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  late final List<_ConfettiPetal> _petals = List.generate(42, (i) {
    final seed = i * 1.618;
    return _ConfettiPetal(
      angle: (seed * 7.3) % (math.pi * 2),
      speed: 140 + (seed * 90) % 220,
      size: 6 + (i % 5) * 2.4,
      spin: (i.isEven ? 1 : -1) * (1.2 + (i % 4) * 0.4),
      delay: (i % 8) * 0.035,
      gravity: 380 + (i % 6) * 40,
      color: [
        AppColors.coral,
        AppColors.roseGold,
        AppColors.peach,
        AppColors.terracotta,
        AppColors.coralSoft,
        AppColors.forest,
      ][i % 6],
    );
  });

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _CelebrationPainter(
              progress: _controller.value,
              petals: _petals,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _ConfettiPetal {
  final double angle;
  final double speed;
  final double size;
  final double spin;
  final double delay;
  final double gravity;
  final Color color;

  const _ConfettiPetal({
    required this.angle,
    required this.speed,
    required this.size,
    required this.spin,
    required this.delay,
    required this.gravity,
    required this.color,
  });
}

class _CelebrationPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiPetal> petals;

  _CelebrationPainter({required this.progress, required this.petals});

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height * 0.34);
    final paint = Paint()..style = PaintingStyle.fill;

    for (final petal in petals) {
      final local = ((progress - petal.delay) / (1 - petal.delay)).clamp(
        0.0,
        1.0,
      );
      if (local <= 0) continue;

      final t = Curves.easeOut.transform(local);
      final dx = math.cos(petal.angle) * petal.speed * t;
      final dy =
          math.sin(petal.angle) * petal.speed * t + 0.5 * petal.gravity * t * t;
      final fade = (1 - local).clamp(0.0, 1.0);

      paint.color = petal.color.withValues(alpha: fade * 0.92);
      canvas.save();
      canvas.translate(origin.dx + dx, origin.dy + dy);
      canvas.rotate(petal.spin * t * math.pi);
      canvas.drawPath(_petal(petal.size * (1.1 - t * 0.25)), paint);
      canvas.restore();
    }
  }

  Path _petal(double size) {
    return Path()
      ..moveTo(0, -size)
      ..cubicTo(size * 0.75, -size * 0.3, size * 0.55, size * 0.45, 0, size)
      ..cubicTo(-size * 0.55, size * 0.45, -size * 0.75, -size * 0.3, 0, -size)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

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
