import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bloom_auth_widgets.dart';
import '../../widgets/bloom_logo.dart';
import '../../widgets/bloom_ui.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AuthService get _authService => ref.read(authServiceProvider);

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showBloomSnack(context, 'Please complete all fields.', isError: true);
      return;
    }

    if (password.length < 6) {
      showBloomSnack(
        context,
        'Password must contain at least 6 characters.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        email: email,
        password: password,
        name: name,
      );

      if (!mounted) return;
      showBloomSnack(context, 'Your Bloom account is ready');

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      context.pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      var message = 'Unable to create your account.';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Please choose a stronger password.';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authCream,
      resizeToAvoidBottomInset: true,
      body: AuthDecorBackground(
        child: AuthScreenFrame(
          header: SizedBox(
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const BloomLogo(showMark: false, titleSize: 28),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.authInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Your Account',
                style: AppText.serif(
                  size: 28,
                  weight: FontWeight.w600,
                  color: AppColors.authInk,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Join Bloom and let flowers be part of your story.',
                style: AppText.sans(
                  size: 13.5,
                  color: AppColors.authMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              AuthField(
                controller: _nameController,
                hint: 'Full Name',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 12),
              AuthField(
                controller: _emailController,
                hint: 'Email Address',
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
                onSubmitted: (_) => _signup(),
              ),
              const SizedBox(height: 16),
              AuthPrimaryButton(
                label: 'Sign Up',
                isLoading: _isLoading,
                onPressed: _signup,
              ),
              const SizedBox(height: 18),
              const AuthDivider(label: 'or sign up with'),
              const SizedBox(height: 14),
              AuthSocialRow(
                onGoogle: () => _comingSoon('Google'),
                onApple: () => _comingSoon('Apple'),
              ),
            ],
          ),
          footer: AuthFooterLink(
            prompt: 'Already have an account? ',
            action: 'Sign In',
            onTap: () => context.pop(),
          ),
        ),
      ),
    );
  }

  void _comingSoon(String provider) {
    showBloomSnack(
      context,
      '$provider sign-up is not enabled yet — use your email for now.',
    );
  }
}
