import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_logo.dart';
import '../auth/login_screen.dart';

class _OnboardPage {
  final String image;
  final String title;
  final String description;

  const _OnboardPage({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  double _pageOffset = 0;

  static const List<_OnboardPage> _pages = [
    _OnboardPage(
      image: AppAssets.onboardingFreshFlowers,
      title: 'Fresh Flowers\nfor a Brighter Day',
      description:
          'Discover the most beautiful flowers for every occasion, '
          'with just a few taps.',
    ),
    _OnboardPage(
      image: AppAssets.onboardingSameDayDelivery,
      title: 'Same Day Delivery',
      description:
          'We bring your emotions right on time, with fresh '
          'and carefully arranged flowers.',
    ),
    _OnboardPage(
      image: AppAssets.onboardingEveryOccasion,
      title: 'Perfect for\nEvery Occasion',
      description:
          'Birthdays, Anniversaries, Congratulations, and more — '
          'we have something for everyone.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _pageOffset = _pageController.page ?? 0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('hasSeenOnboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      BloomPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    final size = MediaQuery.sizeOf(context);
    final imageHeight = (size.height * 0.38).clamp(220.0, 340.0);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BloomMark(size: 30),
                  const SizedBox(width: 10),
                  Text(
                    'BLOOM',
                    style: AppText.wordmark(size: 17),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  // Distance of this page from the viewport centre, used to
                  // drift the artwork for a subtle parallax feel.
                  final delta = (_pageOffset - index).clamp(-1.0, 1.0);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: SizedBox(
                            height: imageHeight,
                            width: double.infinity,
                            child: Transform.scale(
                              scale: 1.16,
                              child: Transform.translate(
                                offset: Offset(delta * 46, 0),
                                child: Image.asset(
                                  page.image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 34),
                        Opacity(
                          opacity: (1 - delta.abs()).clamp(0.0, 1.0),
                          child: Column(
                            children: [
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: AppText.serif(size: 27, height: 1.25),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                page.description,
                                textAlign: TextAlign.center,
                                style: AppText.sans(
                                  size: 13.5,
                                  color: AppColors.muted,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLast ? 'Get Started' : 'Next'),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 17),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: AppText.sans(
                        size: 13,
                        weight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final selected = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: selected ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: selected ? AppColors.forest : AppColors.line,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
