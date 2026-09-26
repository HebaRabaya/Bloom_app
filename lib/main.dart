import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'firebase_options.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const BloomApp());
}

class BloomApp extends StatelessWidget {
  const BloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(
      child: _BloomAppView(),
    );
  }
}

class _BloomAppView extends ConsumerWidget {
  const _BloomAppView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Bloom Flowers',
      theme: AppTheme.light,
      color: AppColors.cream,
      routerConfig: router,
      builder: (context, child) {
        // Keep typography stable if the device font scale is extreme,
        // so cards and buttons never overflow.
        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale.clamp(0.9, 1.15)),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
