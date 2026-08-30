import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

Future<void> main() async {
  // ============================================================
  // Flutter Initialization
  // ============================================================

  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // Firebase Initialization
  // ============================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ============================================================
  // Read Onboarding Status
  // ============================================================

  final preferences = await SharedPreferences.getInstance();

  final hasSeenOnboarding =
      preferences.getBool('hasSeenOnboarding') ?? false;

  // ============================================================
  // Run Application
  // ============================================================

  runApp(
    MyApp(
      hasSeenOnboarding: hasSeenOnboarding,
    ),
  );
}

// ================================================================
// Main Application
// ================================================================

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Bloom',

      // ==========================================================
      // First Screen
      // ==========================================================

      home: hasSeenOnboarding
          ? const LoginScreen()
          : const OnboardingScreen(),
    );
  }
}