import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
