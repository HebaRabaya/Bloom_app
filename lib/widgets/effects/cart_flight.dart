import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

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
