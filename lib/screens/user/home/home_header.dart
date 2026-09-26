import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/bloom_animations.dart';
import '../../../widgets/bloom_logo.dart';
import '../../../widgets/bloom_ui.dart';
import '../user_main_screen.dart';

class HomeHeader extends StatelessWidget {
  final double padding;

  const HomeHeader({super.key, required this.padding});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 6, padding, 4),
        child: Row(
          children: [
            BloomCircleButton(
              icon: Icons.favorite_border_rounded,
              color: AppColors.coral,
              onTap: () => context.push(AppRoutes.favorites),
            ),
            Expanded(
              child: Column(
                children: [
                  const BloomMark(size: 26),
                  const SizedBox(height: 4),
                  Text('BLOOM', style: AppText.wordmark(size: 15)),
                ],
              ),
            ),
            BloomCircleButton(
              icon: Icons.search_rounded,
              onTap: () => UserMainScreen.of(context)?.goToTab(1),
            ),
          ],
        ),
      ),
    );
  }
}
