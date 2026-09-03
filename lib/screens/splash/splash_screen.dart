import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../../theme/app_assets.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_logo.dart';
import '../admin/admin_main_screen.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../user/user_main_screen.dart';

/// Splash from the mockup: peach-rose photograph, rose-gold lotus,
/// white serif wordmark and tagline in the upper third.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3800),
  );

  late final Animation<double> _markDraw = _interval(0.05, 0.45);
  late final Animation<double> _markFade = _interval(0.0, 0.2);
  late final Animation<double> _titleFade = _interval(0.35, 0.6);
  late final Animation<double> _subtitleFade = _interval(0.45, 0.7);
  late final Animation<double> _taglineFade = _interval(0.6, 0.85);

  static const _lightIcons = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  static const _darkIcons = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(_lightIcons);
    _controller.forward();
    _bootstrap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _bootstrap() async {
    final results = await Future.wait<Object?>([
      _resolveDestination(),
      Future<void>.delayed(const Duration(milliseconds: 4800)),
    ]);

    final destination = results.first as Widget;

    if (!mounted) return;

    SystemChrome.setSystemUIOverlayStyle(_darkIcons);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, _, _) => destination,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<Widget> _resolveDestination() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final role = await _authService
            .getUserRole(user.uid)
            .timeout(const Duration(seconds: 6), onTimeout: () => 'user');

        return role == 'admin'
            ? const AdminMainScreen()
            : const UserMainScreen();
      }

      final preferences = await SharedPreferences.getInstance();
      final hasSeenOnboarding =
          preferences.getBool('hasSeenOnboarding') ?? false;

      return hasSeenOnboarding
          ? const LoginScreen()
          : const OnboardingScreen();
    } catch (_) {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _lightIcons,
      child: Scaffold(
        backgroundColor: const Color(0xFFC4B49A),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AppAssets.splashBackground,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, 0.12),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment(0, 0.45),
                      colors: [
                        Color(0x33000000),
                        Color(0x14000000),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: EdgeInsets.only(
                          top: constraints.maxHeight * 0.10,
                        ),
                        child: Column(
                          children: [
                            Opacity(
                              opacity: _markFade.value,
                              child: BloomMark(
                                size: 72,
                                color: AppColors.roseGold,
                                progress: _markDraw.value,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _fadeUp(
                              _titleFade,
                              Text(
                                'BLOOM',
                                style: AppText.serif(
                                  size: 46,
                                  weight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            _fadeUp(
                              _subtitleFade,
                              Text(
                                'FLOWERS',
                                style: AppText.serif(
                                  size: 13,
                                  weight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _fadeUp(
                              _taglineFade,
                              Text(
                                "More than flowers..\nIt's a feeling",
                                textAlign: TextAlign.center,
                                style: AppText.serif(
                                  size: 16,
                                  weight: FontWeight.w400,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _fadeUp(Animation<double> animation, Widget child) {
    return Opacity(
      opacity: animation.value,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - animation.value)),
        child: child,
      ),
    );
  }
}
