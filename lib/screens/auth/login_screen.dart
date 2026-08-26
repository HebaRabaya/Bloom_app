import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';
import '../admin/admin_main_screen.dart';
import '../ profile/profile_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ============================================================
  // Controllers
  // ============================================================

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // ============================================================
  // Service
  // ============================================================

  final _authService = AuthService();

  // ============================================================
  // States
  // ============================================================

  bool _isLoading = false;
  bool _obscurePassword = true;

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // Login
  // ============================================================

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // ----------------------------------------------------------
    // التأكد من تعبئة الحقول
    // ----------------------------------------------------------

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Please enter your email and password.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // 1. تسجيل الدخول باستخدام Firebase Authentication
      // --------------------------------------------------------

      await _authService.login(
        email: email,
        password: password,
      );

      // --------------------------------------------------------
      // 2. الحصول على المستخدم الحالي
      // --------------------------------------------------------

      final user = _authService.currentUser;

      if (user == null) {
        return;
      }

      // --------------------------------------------------------

      // --------------------------------------------------------

      final role = await _authService.getUserRole(
        user.uid,
      );

      if (!mounted) return;

      // --------------------------------------------------------
      // 4. Routing حسب Role
      //
      // admin → AdminMainScreen
      //
      // user → ProfileScreen
      // --------------------------------------------------------

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminMainScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong.';

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
      }

      _showMessage(message);
    } catch (_) {
      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // SnackBar
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.dmSans(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF5A3D43),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F4F1),
      body: Stack(
        children: [
          // ====================================================
          // Decorative Flowers
          // ====================================================

          Positioned(
            top: -45,
            right: -35,
            child: _flowerDecoration(
              'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=700&q=85',
              190,
            ),
          ),

          Positioned(
            bottom: -55,
            left: -45,
            child: _flowerDecoration(
              'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?auto=format&fit=crop&w=700&q=85',
              190,
            ),
          ),

          // ====================================================
          // Page Content
          // ====================================================

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 35),

                  // ==================================================
                  // Logo
                  // ==================================================

                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB86F7B),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB86F7B)
                              .withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_florist_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    'Welcome to',
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      color: const Color(0xFF8A7275),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    'Bloom.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 52,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B3439),
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'A beautiful little space to be yourself.',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: const Color(0xFF8A7275),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 38),

                  // ==================================================
                  // Login Form
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email

                        _inputField(
                          controller: _emailController,
                          label: 'Email address',
                          icon: Icons.mail_outline_rounded,
                          keyboardType:
                          TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 15),

                        // Password

                        _inputField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword =
                                !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF96777D),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // Login Button
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                            _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFFB86F7B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(17),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              'Enter Bloom',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight:
                                FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ==================================================
                  // Go To Signup
                  // ==================================================

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const SignupScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'New to Bloom?  ',
                          style: GoogleFonts.dmSans(
                            color: const Color(0xFF8A7275),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Create an account',
                              style: GoogleFonts.dmSans(
                                color:
                                const Color(0xFF9E5967),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Input Field
  // ============================================================

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.dmSans(
        color: const Color(0xFF4B3439),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(
          color: const Color(0xFF96777D),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFB86F7B),
          size: 21,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9F5F3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFD39AA4),
            width: 1.3,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Flower Decoration
  // ============================================================

  Widget _flowerDecoration(
      String imageUrl,
      double size,
      ) {
    return Opacity(
      opacity: 0.14,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}