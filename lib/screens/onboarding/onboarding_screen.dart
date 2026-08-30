import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
  });

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ============================================================
  // Page Controller
  // ============================================================

  final PageController _pageController =
  PageController();

  int _currentPage = 0;

  // ============================================================
  // Onboarding Pages
  // ============================================================

  final List<Map<String, String>> _pages = [
    {
      'title': 'Beautiful Flowers',
      'description':
      'Discover beautiful flowers and lovely arrangements made for every special moment.',
      'image':
      'https://images.unsplash.com/photo-1490750967868-88aa4486c946',
    },
    {
      'title': 'Choose Your Favorites',
      'description':
      'Explore our collection and find the perfect flowers for yourself or someone you love.',
      'image':
      'https://images.unsplash.com/photo-1497250681960-ef046c08a56e',
    },
    {
      'title': 'Easy Shopping',
      'description':
      'Add your favorite products to your cart and manage your order easily.',
      'image':
      'https://images.unsplash.com/photo-1523438885200-e635ba2c371e',
    },
  ];

  // ============================================================
  // Finish Onboarding
  // ============================================================

  Future<void> _finishOnboarding() async {
    final preferences =
    await SharedPreferences.getInstance();

    // حفظ أن المستخدم شاهد الـ Onboarding
    await preferences.setBool(
      'hasSeenOnboarding',
      true,
    );

    if (!mounted) {
      return;
    }

    // الانتقال إلى Login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  // ============================================================
  // Next Page
  // ============================================================

  void _nextPage() {
    if (_currentPage == _pages.length - 1) {
      _finishOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(
        milliseconds: 400,
      ),
      curve: Curves.easeInOut,
    );
  }

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // Build
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4F1),

      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // Skip Button
            // ==================================================

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  right: 20,
                ),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFF92797E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // Onboarding Pages
            // ==================================================

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,

                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                    ),

                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [
                        // ======================================
                        // Image
                        // ======================================

                        ClipRRect(
                          borderRadius:
                          BorderRadius.circular(30),

                          child: Image.network(
                            page['image']!,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,

                            errorBuilder:
                                (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 300,
                                color:
                                const Color(0xFFE8D1D4),

                                child: const Icon(
                                  Icons.local_florist,
                                  size: 80,
                                  color:
                                  Color(0xFFB86F7B),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 35),

                        // ======================================
                        // Title
                        // ======================================

                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,

                          style:
                          GoogleFonts.playfairDisplay(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color:
                            const Color(0xFF4B3439),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ======================================
                        // Description
                        // ======================================

                        Text(
                          page['description']!,
                          textAlign: TextAlign.center,

                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            height: 1.6,
                            color:
                            const Color(0xFF7D696D),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ==================================================
            // Page Indicator
            // ==================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: List.generate(
                _pages.length,
                    (index) {
                  final isSelected =
                      index == _currentPage;

                  return AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 250),

                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),

                    width:
                    isSelected ? 25 : 8,

                    height: 8,

                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFB86F7B)
                          : const Color(0xFFE1BFC4),

                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // Next / Get Started Button
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                25,
                0,
                25,
                25,
              ),

              child: SizedBox(
                width: double.infinity,
                height: 55,

                child: ElevatedButton(
                  onPressed: _nextPage,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFB86F7B),

                    foregroundColor:
                    Colors.white,

                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),

                  child: Text(
                    _currentPage ==
                        _pages.length - 1
                        ? 'Get Started'
                        : 'Next',

                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}