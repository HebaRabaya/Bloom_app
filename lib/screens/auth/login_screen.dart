import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_animations.dart';
import '../../widgets/bloom_auth_widgets.dart';
import '../../widgets/bloom_logo.dart';
import '../../widgets/bloom_ui.dart';
import '../admin/admin_main_screen.dart';
import '../user/user_main_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // Sign In
  // ============================================================

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showBloomSnack(
        context,
        'Please enter your email and password.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(email: email, password: password);

      final user = _authService.currentUser;
      if (user == null) return;

      final role = await _authService.getUserRole(user.uid);
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        BloomPageRoute(
          builder: (_) => role == 'admin'
              ? const AdminMainScreen()
              : const UserMainScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      var message = 'Something went wrong.';
      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'Incorrect email or password.';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;
      }
      showBloomSnack(context, message, isError: true);
    } catch (_) {
      if (!mounted) return;
      showBloomSnack(
        context,
        'Something went wrong. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // Forgot Password
  // ============================================================

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(
      text: _emailController.text.trim(),
    );

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We will email you a secure link to choose a new password.',
                style: AppText.sans(size: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              AuthField(
                controller: controller,
                hint: 'Email address',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, controller.text.trim());
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120, 44),
              ),
              child: const Text('Send link'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (email == null || email.isEmpty) return;
    if (!mounted) return;

    try {
      await _authService.sendPasswordReset(email: email);
      if (!mounted) return;
      showBloomSnack(context, 'Reset link sent to $email');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showBloomSnack(
        context,
        e.code == 'invalid-email'
            ? 'Please enter a valid email address.'
            : 'We could not send the reset link.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authCream,
      resizeToAvoidBottomInset: true,
      body: AuthDecorBackground(
        child: AuthScreenFrame(
          header: const BloomLogo(showMark: false, titleSize: 34),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: AppText.serif(
                  size: 32,
                  weight: FontWeight.w600,
                  color: AppColors.authInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please sign in to your account',
                style: AppText.sans(size: 13.5, color: AppColors.authMuted),
              ),
              const SizedBox(height: 22),
              AuthField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              AuthField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 18),
              AuthPrimaryButton(
                label: 'Sign In',
                isLoading: _isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 14),
              Center(
                child: GestureDetector(
                  onTap: _forgotPassword,
                  child: Text(
                    'Forgot password?',
                    style: AppText.serif(
                      size: 14.5,
                      weight: FontWeight.w500,
                      color: AppColors.authTerracotta,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.authTerracotta,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const AuthDivider(label: 'or sign in with'),
              const SizedBox(height: 16),
              AuthSocialRow(
                onGoogle: () => _comingSoon('Google'),
                onApple: () => _comingSoon('Apple'),
              ),
            ],
          ),
          footer: AuthFooterLink(
            prompt: "Don't have an account? ",
            action: 'Sign Up',
            onTap: () {
              Navigator.push(
                context,
                BloomPageRoute(builder: (_) => const SignupScreen()),
              );
            },
          ),
        ),
      ),
    );
  }

  void _comingSoon(String provider) {
    showBloomSnack(
      context,
      '$provider sign-in is not enabled yet — use your email for now.',
    );
  }
}
