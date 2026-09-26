import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

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
