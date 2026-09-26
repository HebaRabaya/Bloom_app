import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/order_model.dart';
import '../models/product_model.dart';
import '../providers/auth_providers.dart';
import '../screens/admin/add_product_screen.dart';
import '../screens/admin/admin_main_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/user/checkout_screen.dart';
import '../screens/user/favorites_screen.dart';
import '../screens/user/order_success_screen.dart';
import '../screens/user/order_tracking_screen.dart';
import '../screens/user/product_details_screen.dart';
import '../screens/user/search_screen.dart';
import '../screens/user/user_main_screen.dart';
import '../services/auth_service.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const user = '/user';
  static const admin = '/admin';
  static const search = '/search';
  static const favorites = '/favorites';
  static const product = '/product';
  static const checkout = '/checkout';
  static const orderSuccess = '/order-success';
  static const orderTracking = '/order';
  static const editProfile = '/profile/edit';
  static const adminEditProduct = '/admin/product/edit';
}

class ProductRouteExtra {
  const ProductRouteExtra({
    required this.product,
    required this.heroTag,
  });

  final ProductModel product;
  final String heroTag;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.read(authServiceProvider);
  return createAppRouter(authService);
});

GoRouter createAppRouter(AuthService authService) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) => _redirect(state, authService),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.user,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const UserMainScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.admin,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const AdminMainScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) {
          final category = state.uri.queryParameters['category'];
          return _bloomPage(
            state: state,
            child: SearchScreen(
              initialCategory:
                  (category == null || category.isEmpty) ? null : category,
              showBackButton: state.uri.queryParameters['back'] == '1',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.favorites,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const FavoritesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.product,
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra is ProductRouteExtra) {
            return _bloomPage(
              state: state,
              child: ProductDetailsScreen(
                product: extra.product,
                heroTag: extra.heroTag,
              ),
            );
          }
          return _bloomPage(
            state: state,
            child: const UserMainScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        pageBuilder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'] ?? '';
          return _bloomPage(
            state: state,
            child: OrderSuccessScreen(orderId: orderId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.orderTracking,
        pageBuilder: (context, state) {
          final extra = state.extra;
          if (extra is OrderModel) {
            return _bloomPage(
              state: state,
              child: OrderTrackingScreen(order: extra),
            );
          }
          return _bloomPage(
            state: state,
            child: const UserMainScreen(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) => _bloomPage(
          state: state,
          child: const EditProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.adminEditProduct,
        pageBuilder: (context, state) {
          final extra = state.extra;
          return _bloomPage(
            state: state,
            child: AddProductScreen(
              product: extra is ProductModel ? extra : null,
            ),
          );
        },
      ),
    ],
  );
}

Future<String?> _redirect(GoRouterState state, AuthService authService) async {
  final path = state.uri.path;

  // Splash decides the first destination after its own animation.
  if (path == AppRoutes.splash) return null;

  final user = FirebaseAuth.instance.currentUser;
  final public = path == AppRoutes.login ||
      path == AppRoutes.signup ||
      path == AppRoutes.onboarding;

  if (user == null) {
    return public ? null : AppRoutes.login;
  }

  final isAdminPath =
      path == AppRoutes.admin || path.startsWith('${AppRoutes.admin}/');

  if (isAdminPath) {
    final role = await authService
        .getUserRole(user.uid)
        .timeout(const Duration(seconds: 6), onTimeout: () => 'user');

    if (role != 'admin') return AppRoutes.user;
  }

  return null;
}

CustomTransitionPage<T> _bloomPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
