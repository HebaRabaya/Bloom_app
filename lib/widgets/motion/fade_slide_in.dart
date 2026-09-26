import 'package:flutter/material.dart';

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
