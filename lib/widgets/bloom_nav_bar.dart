import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'bloom_animations.dart';
import 'bloom_wow.dart';

class BloomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BloomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Bottom navigation bar from the mockup: a floating white bar with a soft
/// pill behind the active tab. It hides while the keyboard is open so it can
/// never overflow the layout.
class BloomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<BloomNavItem> items;
  final Map<int, int> badges;

  const BloomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.items,
    this.badges = const {},
  });

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AnimatedSlide(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      offset: keyboardOpen ? const Offset(0, 1.4) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: keyboardOpen ? 0 : 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: AppColors.taupe.withValues(alpha: 0.22),
                blurRadius: 26,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavButton(
                        item: items[i],
                        selected: i == currentIndex,
                        badge: badges[i] ?? 0,
                        iconKey: i == 2 ? BloomCartFlight.cartIconKey : null,
                        bounceListenable: i == 2
                            ? BloomCartFlight.arrivalTick
                            : null,
                        onTap: () => onChanged(i),
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

class _NavButton extends StatelessWidget {
  final BloomNavItem item;
  final bool selected;
  final int badge;
  final VoidCallback onTap;
  final GlobalKey? iconKey;
  final ValueNotifier<int>? bounceListenable;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.badge,
    required this.onTap,
    this.iconKey,
    this.bounceListenable,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.forest : AppColors.taupe;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      splashColor: AppColors.forestSoft,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 18 : 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: selected ? AppColors.forestSoft : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  KeyedSubtree(
                    key: iconKey,
                    child: bounceListenable == null
                        ? Icon(
                            selected ? item.activeIcon : item.icon,
                            size: 21,
                            color: color,
                          )
                        : ValueListenableBuilder<int>(
                            valueListenable: bounceListenable!,
                            builder: (context, tick, child) {
                              if (tick == 0) return child!;
                              return TweenAnimationBuilder<double>(
                                key: ValueKey(tick),
                                tween: Tween(begin: 0.7, end: 1),
                                duration: const Duration(milliseconds: 560),
                                curve: Curves.elasticOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                child: child,
                              );
                            },
                            child: Icon(
                              selected ? item.activeIcon : item.icon,
                              size: 21,
                              color: color,
                            ),
                          ),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: BloomCountBadge(count: badge),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: AppText.sans(
                size: 10,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
