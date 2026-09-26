import 'package:flutter/material.dart';

import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../bloom_animations.dart';

// ============================================================
// States
// ============================================================

class BloomLoader extends StatelessWidget {
  final String? message;

  const BloomLoader({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              color: AppColors.forest,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 14),
            Text(
              message!,
              style: AppText.sans(size: 12.5, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// Friendly empty state with an illustration, copy and an optional action.
///
/// When [mood] is set, the scene comes alive: drifting petals, a breathing
/// glow, and a floating illustration so the pause still feels like Bloom.
class BloomEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final String illustration;
  final BloomPetalMood? mood;

  const BloomEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.illustration = AppAssets.emptyStateIllustration,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    final living = mood != null;
    final glowColor = mood == BloomPetalMood.favorite
        ? AppColors.coralSoft
        : AppColors.peach;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeSlideIn(
          offsetY: 18,
          duration: const Duration(milliseconds: 640),
          child: SizedBox(
            height: living ? 230 : 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (living) BloomGlowPulse(size: 220, color: glowColor),
                living
                    ? BloomFloat(
                        distance: 9,
                        tilt: 0.028,
                        child: Image.asset(illustration, fit: BoxFit.contain),
                      )
                    : Image.asset(illustration, fit: BoxFit.contain),
                if (icon != null)
                  Positioned(
                    bottom: living ? 10 : 6,
                    child: living
                        ? BloomBreathe(maxScale: 1.06, child: _emptyIcon(icon!))
                        : _emptyIcon(icon!),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.serif(size: 22),
          ),
        ),
        const SizedBox(height: 8),
        FadeSlideIn(
          delay: const Duration(milliseconds: 190),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.sans(size: 13, color: AppColors.muted, height: 1.6),
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 280),
            child: living
                ? BloomBreathe(
                    maxScale: 1.03,
                    child: SizedBox(
                      width: 210,
                      child: ElevatedButton(
                        onPressed: onAction,
                        child: Text(actionLabel!),
                      ),
                    ),
                  )
                : SizedBox(
                    width: 210,
                    child: ElevatedButton(
                      onPressed: onAction,
                      child: Text(actionLabel!),
                    ),
                  ),
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            if (living)
              Positioned.fill(
                child: IgnorePointer(
                  child: BloomPetalField(mood: mood!, count: 14),
                ),
              ),
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight.isFinite
                      ? constraints.maxHeight - 48
                      : 0,
                ),
                child: Center(child: content),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.coral.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.coral, size: 22),
    );
  }
}

/// Price label with the brand's coral emphasis.
class BloomPrice extends StatelessWidget {
  final double value;
  final double size;
  final Color color;

  const BloomPrice({
    super.key,
    required this.value,
    this.size = 15,
    this.color = AppColors.coral,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '\$${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 2)}',
      style: AppText.sans(size: size, weight: FontWeight.w700, color: color),
    );
  }
}
