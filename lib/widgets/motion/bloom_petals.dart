import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
