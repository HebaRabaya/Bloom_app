import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Outline lotus mark from the splash mockup: five petals in rose gold.
class BloomMark extends StatelessWidget {
  final double size;
  final Color color;
  final double progress;

  const BloomMark({
    super.key,
    this.size = 48,
    this.color = AppColors.roseGold,
    this.progress = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.78,
      child: CustomPaint(
        painter: _LotusPainter(color: color, progress: progress),
      ),
    );
  }
}

class _LotusPainter extends CustomPainter {
  final Color color;
  final double progress;

  _LotusPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.042
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final unit = size.height;

    const petals = <List<double>>[
      [-68, 0.70, 0.28],
      [68, 0.70, 0.28],
      [-34, 0.88, 0.24],
      [34, 0.88, 0.24],
      [0, 1.0, 0.22],
    ];

    canvas.save();
    canvas.translate(size.width / 2, size.height * 0.98);

    for (final petal in petals) {
      canvas.save();
      canvas.rotate(petal[0] * math.pi / 180);
      canvas.drawPath(
        _trim(
          _petalPath(length: unit * petal[1], width: unit * petal[2]),
          progress,
        ),
        paint,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  Path _petalPath({required double length, required double width}) {
    return Path()
      ..moveTo(0, 0)
      ..cubicTo(-width, -length * 0.32, -width * 0.62, -length * 0.72, 0, -length)
      ..cubicTo(width * 0.62, -length * 0.72, width, -length * 0.32, 0, 0);
  }

  Path _trim(Path path, double amount) {
    if (amount >= 1) return path;

    final trimmed = Path();
    for (final metric in path.computeMetrics()) {
      trimmed.addPath(
        metric.extractPath(0, metric.length * amount),
        Offset.zero,
      );
    }
    return trimmed;
  }

  @override
  bool shouldRepaint(_LotusPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// BLOOM / FLOWERS lockup. Auth screens hide the lotus; splash shows it.
class BloomLogo extends StatelessWidget {
  final double markSize;
  final double titleSize;
  final Color color;
  final Color? subtitleColor;
  final double markProgress;
  final bool showMark;

  const BloomLogo({
    super.key,
    this.markSize = 46,
    this.titleSize = 24,
    this.color = AppColors.ink,
    this.subtitleColor,
    this.markProgress = 1,
    this.showMark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMark) ...[
          BloomMark(
            size: markSize,
            color: AppColors.roseGold,
            progress: markProgress,
          ),
          SizedBox(height: titleSize * 0.34),
        ],
        Text(
          'BLOOM',
          style: AppText.serif(
            size: titleSize,
            weight: FontWeight.w600,
            color: color,
            letterSpacing: titleSize * 0.06,
          ),
        ),
        SizedBox(height: titleSize * 0.02),
        Text(
          'FLOWERS',
          style: AppText.serif(
            size: titleSize * 0.32,
            weight: FontWeight.w400,
            color: subtitleColor ?? color,
            letterSpacing: titleSize * 0.48,
          ),
        ),
      ],
    );
  }
}
