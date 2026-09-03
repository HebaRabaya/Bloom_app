import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'bloom_animations.dart';

// ============================================================
// Layout helpers
// ============================================================

double bloomPagePadding(double width) {
  if (width >= 900) return 40;
  if (width >= 600) return 28;
  return 20;
}

int bloomGridCount(double width) {
  if (width >= 1100) return 4;
  if (width >= 720) return 3;
  return 2;
}

void showBloomSnack(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.local_florist_rounded,
              size: 18,
              color: isError ? AppColors.coralSoft : AppColors.peach,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppText.sans(size: 13.5, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.forestDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
}

// ============================================================
// Images
// ============================================================

/// Network image with a soft shimmer placeholder, a fade-in once decoded,
/// and a branded fallback when the URL is missing or broken.
class BloomImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final String? fallbackAsset;

  const BloomImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackAsset,
  });

  @override
  Widget build(BuildContext context) {
    if (url.trim().isEmpty) return _fallback();

    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => _fallback(),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          child: frame == null
              ? const BloomShimmer(key: ValueKey('shimmer'))
              : KeyedSubtree(key: const ValueKey('image'), child: child),
        );
      },
    );
  }

  Widget _fallback() {
    if (fallbackAsset != null) {
      return Image.asset(
        fallbackAsset!,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return Container(
      color: AppColors.blush,
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_florist_rounded,
        color: AppColors.coralSoft,
        size: 34,
      ),
    );
  }
}

/// Looping shimmer used while images and lists load.
class BloomShimmer extends StatefulWidget {
  final BorderRadius? borderRadius;

  const BloomShimmer({super.key, this.borderRadius});

  @override
  State<BloomShimmer> createState() => _BloomShimmerState();
}

class _BloomShimmerState extends State<BloomShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
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
        final value = _controller.value * 2 - 1;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + value, -0.4),
              end: Alignment(1 + value, 0.4),
              colors: const [
                AppColors.creamDeep,
                AppColors.blush,
                AppColors.creamDeep,
              ],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

// ============================================================
// Surfaces
// ============================================================

class BloomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final VoidCallback? onTap;

  const BloomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.radius = AppTheme.radiusCard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.taupe.withValues(alpha: 0.13),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return PressableScale(onTap: onTap, child: card);
  }
}

/// Circular icon button used for back arrows, hearts and share actions.
class BloomCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final Color color;
  final double size;

  const BloomCircleButton({
    super.key,
    required this.icon,
    this.onTap,
    this.background = Colors.white,
    this.color = AppColors.ink,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.44, color: color),
        ),
      ),
    );
  }
}

class BloomSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BloomSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppText.serif(size: 20))),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: AppText.sans(
                size: 12.5,
                weight: FontWeight.w600,
                color: AppColors.coral,
              ),
            ),
          ),
      ],
    );
  }
}

/// Pill filter chip matching the mockup's category selector.
class BloomChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const BloomChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.forest : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.forest : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: AppText.sans(
            size: 12.5,
            weight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

/// Quantity stepper shared by the product page and the cart.
class BloomQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final bool compact;

  const BloomQuantityStepper({
    super.key,
    required this.quantity,
    this.onIncrease,
    this.onDecrease,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 28.0 : 34.0;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.creamDeep,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(Icons.remove_rounded, onDecrease, size),
          Container(
            constraints: BoxConstraints(minWidth: size),
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: AppText.sans(
                size: compact ? 13 : 14.5,
                weight: FontWeight.w600,
              ),
            ),
          ),
          _button(Icons.add_rounded, onIncrease, size),
        ],
      ),
    );
  }

  Widget _button(IconData icon, VoidCallback? onTap, double size) {
    final enabled = onTap != null;

    return Material(
      color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size * 0.52,
            color: enabled ? AppColors.forest : AppColors.taupe,
          ),
        ),
      ),
    );
  }
}

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
class BloomEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final String illustration;

  const BloomEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.illustration = AppAssets.emptyStateIllustration,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeSlideIn(
          offsetY: 14,
          child: SizedBox(
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(illustration, fit: BoxFit.contain),
                if (icon != null)
                  Positioned(
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppColors.coral, size: 22),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        FadeSlideIn(
          delay: const Duration(milliseconds: 90),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.serif(size: 22),
          ),
        ),
        const SizedBox(height: 8),
        FadeSlideIn(
          delay: const Duration(milliseconds: 150),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: AppText.sans(
              size: 13,
              color: AppColors.muted,
              height: 1.6,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 24),
          FadeSlideIn(
            delay: const Duration(milliseconds: 210),
            child: SizedBox(
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
        return SingleChildScrollView(
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
        );
      },
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
