import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'bloom_logo.dart';

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
