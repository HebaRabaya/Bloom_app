import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/bloom_animations.dart';
import '../user_main_screen.dart';

class HomeSearchBar extends StatelessWidget {
  final double padding;

  const HomeSearchBar({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 70),
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 14, padding, 0),
        child: PressableScale(
          onTap: () => UserMainScreen.of(context)?.goToTab(1),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 19,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 10),
                Text(
                  'Search for flowers…',
                  style: AppText.sans(size: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
