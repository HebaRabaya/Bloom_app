import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'bloom_wow.dart';

/// Fades and lifts its child into place once, optionally after a delay.
///
/// Used to stagger lists and page sections so screens feel composed
/// instead of snapping in all at once.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final double offsetX;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 460),
    this.offsetY = 24,
    this.offsetX = 0,
  });

  /// Convenience constructor for staggering items inside a list or grid.
  factory FadeSlideIn.staggered({
    Key? key,
    required int index,
    required Widget child,
    double offsetY = 24,
    int stepMilliseconds = 60,
    int maxSteps = 8,
  }) {
    final step = index.clamp(0, maxSteps);
    return FadeSlideIn(
      key: key,
      delay: Duration(milliseconds: step * stepMilliseconds),
      offsetY: offsetY,
      child: child,
    );
  }

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(
              widget.offsetX * (1 - _curve.value),
              widget.offsetY * (1 - _curve.value),
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Scales its child down slightly while pressed, giving buttons and cards
/// a tactile feel.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.borderRadius,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Shared page route: content fades while sliding a short distance up,
/// matching the calm rhythm of the rest of the app.
class BloomPageRoute<T> extends PageRouteBuilder<T> {
  BloomPageRoute({required WidgetBuilder builder})
    : super(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (context, animation, secondaryAnimation) {
          return builder(context);
        },
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
}

/// Gentle vertical bob with a tiny tilt — used by empty states and
/// onboarding artwork so still images feel alive.
class BloomFloat extends StatefulWidget {
  final Widget child;
  final double distance;
  final double tilt;
  final Duration duration;

  const BloomFloat({
    super.key,
    required this.child,
    this.distance = 8,
    this.tilt = 0.03,
    this.duration = const Duration(milliseconds: 2800),
  });

  @override
  State<BloomFloat> createState() => _BloomFloatState();
}

class _BloomFloatState extends State<BloomFloat>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final signed = t * 2 - 1;
        return Transform.translate(
          offset: Offset(0, signed * widget.distance),
          child: Transform.rotate(angle: signed * widget.tilt, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// Soft scale breathe. Keeps a call-to-action from feeling frozen.
class BloomBreathe extends StatefulWidget {
  final Widget child;
  final double maxScale;
  final Duration duration;

  const BloomBreathe({
    super.key,
    required this.child,
    this.maxScale = 1.035,
    this.duration = const Duration(milliseconds: 1800),
  });

  @override
  State<BloomBreathe> createState() => _BloomBreatheState();
}

class _BloomBreatheState extends State<BloomBreathe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final scale = 1 + (widget.maxScale - 1) * t;
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}

/// Radial blush glow that pulses behind an illustration.
class BloomGlowPulse extends StatefulWidget {
  final double size;
  final Color color;

  const BloomGlowPulse({
    super.key,
    this.size = 220,
    this.color = AppColors.peach,
  });

  @override
  State<BloomGlowPulse> createState() => _BloomGlowPulseState();
}

class _BloomGlowPulseState extends State<BloomGlowPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

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
        final t = Curves.easeInOut.transform(_controller.value);
        final scale = 0.86 + t * 0.18;
        final opacity = 0.28 + t * 0.22;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.color.withValues(alpha: opacity),
                  widget.color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Palette for drifting petals so cart and favorites feel related, not identical.
enum BloomPetalMood { cart, favorite, garden }

/// Slow falling petals painted behind empty states and onboarding.
class BloomPetalField extends StatefulWidget {
  final BloomPetalMood mood;
  final int count;

  const BloomPetalField({
    super.key,
    this.mood = BloomPetalMood.garden,
    this.count = 12,
  });

  @override
  State<BloomPetalField> createState() => _BloomPetalFieldState();
}

class _BloomPetalFieldState extends State<BloomPetalField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 14000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _PetalPainter(
              progress: _controller.value,
              mood: widget.mood,
              count: widget.count,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _PetalPainter extends CustomPainter {
  final double progress;
  final BloomPetalMood mood;
  final int count;

  _PetalPainter({
    required this.progress,
    required this.mood,
    required this.count,
  });

  static const _garden = [
    AppColors.coral,
    AppColors.roseGold,
    AppColors.peach,
    AppColors.terracotta,
    AppColors.coralSoft,
  ];

  static const _cart = [
    AppColors.forest,
    AppColors.roseGold,
    AppColors.peach,
    AppColors.terracotta,
    AppColors.coralSoft,
  ];

  static const _favorite = [
    AppColors.coral,
    AppColors.coralSoft,
    AppColors.roseGold,
    AppColors.peach,
    AppColors.terracotta,
  ];

  List<Color> get _palette {
    switch (mood) {
      case BloomPetalMood.cart:
        return _cart;
      case BloomPetalMood.favorite:
        return _favorite;
      case BloomPetalMood.garden:
        return _garden;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final palette = _palette;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < count; i++) {
      final seed = i * 0.6180339887;
      final speed = 0.45 + (seed % 0.55);
      final phase = (seed * 7) % 1;
      final t = (progress * speed + phase) % 1.0;
      final startX = (seed * 1.37) % 1.0;
      final sway = 18.0 + (i % 5) * 7;
      final x =
          startX * size.width + math.sin((t + phase) * math.pi * 2) * sway;
      final y = -28 + t * (size.height + 56);
      final petalSize = 5.5 + (i % 4) * 2.2;
      final rotation = t * math.pi * 2 * (i.isEven ? 1 : -1) + phase;
      final fade = math.sin(t * math.pi).clamp(0.0, 1.0);
      final color = palette[i % palette.length];

      paint.color = color.withValues(alpha: 0.18 + fade * 0.38);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.drawPath(_petal(petalSize), paint);
      canvas.restore();
    }
  }

  Path _petal(double size) {
    return Path()
      ..moveTo(0, -size)
      ..cubicTo(size * 0.7, -size * 0.35, size * 0.55, size * 0.45, 0, size)
      ..cubicTo(-size * 0.55, size * 0.45, -size * 0.7, -size * 0.35, 0, -size)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _PetalPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.mood != mood ||
        oldDelegate.count != count;
  }
}

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
