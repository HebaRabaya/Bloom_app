import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';

Future<void> main() async {
  // لازم قبل أي Firebase operation
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // Initialize Firebase
  // ============================================================

  await Firebase.initializeApp(
    options:
    DefaultFirebaseOptions
        .currentPlatform,
  );

  runApp(
    const BloomApp(),
  );
}

class BloomApp
    extends StatelessWidget {
  const BloomApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
      false,

      title: 'Bloom',

      home:
      const LoginScreen(),
    );
  }
}