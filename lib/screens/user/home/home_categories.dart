import 'package:flutter/material.dart';

import '../../../models/category_model.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/bloom_animations.dart';

class HomeCategories extends StatelessWidget {
  final double padding;
  final Stream<List<CategoryModel>> stream;
  final ValueChanged<String> onCategoryTap;

  const HomeCategories({
    super.key,
    required this.padding,
    required this.stream,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryModel>>(
      stream: stream,
      builder: (context, snapshot) {
        final categories = snapshot.data ?? [];
        if (categories.isEmpty) return const SizedBox(height: 18);

        return FadeSlideIn(
          delay: const Duration(milliseconds: 170),
          child: Padding(
            padding: const EdgeInsets.only(top: 22),
            child: SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: padding),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final name = categories[index].name;

                  return PressableScale(
                    onTap: () => onCategoryTap(name),
                    child: SizedBox(
                      width: 72,
                      child: Column(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.line,
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: ClipOval(
                              child: Image.asset(
                                AppAssets.categoryFallback(name),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppText.sans(
                              size: 11,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
