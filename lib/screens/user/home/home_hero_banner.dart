import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/bloom_animations.dart';
import '../../../widgets/bloom_wow.dart';
import '../user_main_screen.dart';

class HomeHeroBanner extends StatelessWidget {
  final double padding;
  final double parallax;

  const HomeHeroBanner({
    super.key,
    required this.padding,
    required this.parallax,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: const Duration(milliseconds: 120),
      child: Padding(
        padding: EdgeInsets.fromLTRB(padding, 18, padding, 0),
        child: BloomCinematicBanner(
          parallax: parallax,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: SizedBox(
              width: 190,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BIGGER.', style: AppText.serif(size: 21, height: 1.15)),
                  Text(
                    'BRIGHTER.',
                    style: AppText.serif(
                      size: 21,
                      height: 1.15,
                      color: AppColors.coral,
                    ),
                  ),
                  Text('BETTER.', style: AppText.serif(size: 21, height: 1.15)),
                  const SizedBox(height: 10),
                  Text(
                    'Thoughtfully designed flowers and gifts '
                    'for every meaningful moment.',
                    style: AppText.sans(
                      size: 11,
                      color: AppColors.ink.withValues(alpha: 0.72),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  BloomBreathe(
                    child: PressableScale(
                      onTap: () => UserMainScreen.of(context)?.goToTab(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Shop Now',
                              style: AppText.sans(
                                size: 12,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
