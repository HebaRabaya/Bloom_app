import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/cart_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'bloom_logo.dart';
import 'bloom_ui.dart';

/// A living bouquet that grows as cart items are added.
class BloomLivingVase extends StatelessWidget {
  final List<CartModel> items;

  const BloomLivingVase({super.key, required this.items});

  List<String> get _blooms {
    final urls = <String>[];
    for (final item in items) {
      final copies = item.quantity.clamp(1, 3);
      for (var i = 0; i < copies; i++) {
        urls.add(item.productImage);
        if (urls.length >= 7) return urls;
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final blooms = _blooms;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.82, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        height: 176,
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.45,
                  child: CustomPaint(painter: _VasePainter()),
                ),
              ),
            ),
            for (var i = 0; i < blooms.length; i++)
              _bloomAt(i, blooms.length, blooms[i]),
            Positioned(
              bottom: 10,
              child: Text(
                blooms.length == 1
                    ? 'Your bouquet is beginning'
                    : 'Your bouquet is taking shape',
                style: AppText.sans(size: 11, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bloomAt(int index, int total, String url) {
    final t = total == 1 ? 0.5 : index / (total - 1);
    final angle = -0.72 + t * 1.44;
    final lift = 58 + math.sin(t * math.pi) * 22;

    return Positioned(
      bottom: 36 + lift * 0.15,
      child: Transform.translate(
        offset: Offset(math.sin(angle) * 78, -lift),
        child: Transform.rotate(
          angle: angle * 0.35,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.2, end: 1),
            duration: Duration(milliseconds: 480 + index * 90),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coral.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: BloomImage(url: url),
            ),
          ),
        ),
      ),
    );
  }
}

class _VasePainter extends CustomPainter {
  const _VasePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final vase = Path()
      ..moveTo(size.width * 0.38, size.height * 0.58)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.7,
        size.width * 0.32,
        size.height * 0.88,
        size.width * 0.36,
        size.height * 0.92,
      )
      ..lineTo(size.width * 0.64, size.height * 0.92)
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.88,
        size.width * 0.66,
        size.height * 0.7,
        size.width * 0.62,
        size.height * 0.58,
      )
      ..close();

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD9C4A8), AppColors.terracotta],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(vase, fill);

    final stem = Paint()
      ..color = AppColors.forest.withValues(alpha: 0.55)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final x in [0.44, 0.5, 0.56]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.58),
        Offset(size.width * x, size.height * 0.34),
        stem,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pull-to-refresh draws the lotus until it blooms.
class BloomRefreshLotus extends StatelessWidget {
  final double progress;
  final bool refreshing;

  const BloomRefreshLotus({
    super.key,
    required this.progress,
    required this.refreshing,
  });

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Transform.scale(
          scale: 0.86 + t * 0.22,
          child: BloomMark(
            size: 52,
            color: AppColors.roseGold,
            progress: refreshing ? 1 : t,
          ),
        ),
      ),
    );
  }
}
