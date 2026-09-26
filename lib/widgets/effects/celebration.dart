import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
