import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // ============================================================
  // Controllers
  // ============================================================

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ============================================================
  // Service
  // ============================================================

  final _authService = AuthService();

  // ============================================================
  // States
  // ============================================================

  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ============================================================
  // Selected Account Role
  //
  // القيمة الافتراضية لأي مستخدم جديد هي user
  // ============================================================

  String _selectedRole = 'user';

  // ============================================================
  // Dispose
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // Sign Up
  // ============================================================

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // ----------------------------------------------------------
    // التأكد من تعبئة جميع الحقول
    // ----------------------------------------------------------

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Please complete all fields.');
      return;
    }

    // ----------------------------------------------------------
    // التأكد من تطابق كلمات المرور
    // ----------------------------------------------------------

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    // ----------------------------------------------------------
    // Firebase يحتاج كلمة مرور 6 أحرف على الأقل
    // ----------------------------------------------------------

    if (password.length < 6) {
      _showMessage(
        'Password must contain at least 6 characters.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // --------------------------------------------------------
      // إنشاء الحساب
      //
      // AuthService رح يعمل:
      // 1. إنشاء المستخدم في Firebase Authentication
      // 2. حفظ الاسم
      // 3. إنشاء Document داخل users
      // 4. حفظ الـ role
      // --------------------------------------------------------

      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: _selectedRole,
      );

      if (!mounted) return;

      _showMessage(
        'Your Bloom account is ready 🌷',
      );

      // --------------------------------------------------------
      // تأخير بسيط حتى تظهر رسالة النجاح
      // --------------------------------------------------------

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      // --------------------------------------------------------
      // الرجوع إلى شاشة Login
      // --------------------------------------------------------

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Unable to create your account.';

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
          // Decorative Flower
          // ====================================================

          Positioned(
            top: -55,
            left: -55,
            child: _flowerDecoration(
              'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=700&q=85',
              200,
            ),
          ),

          Positioned(
            bottom: -55,
            right: -50,
            child: _flowerDecoration(
              'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?auto=format&fit=crop&w=700&q=85',
              200,
            ),
          ),

          // ====================================================
          // Page Content
          // ====================================================

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رجوع إلى Login

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 19,
                    ),
                    color: const Color(0xFF5A3D43),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Begin your',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: const Color(0xFF8A7275),
                    ),
                  ),

                  Text(
                    'Bloom.',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 50,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4B3439),
                      height: 1.05,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create your personal space and let your story grow.',
                    style: GoogleFonts.dmSans(
                      fontSize: 14.5,
                      color: const Color(0xFF8A7275),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ==================================================
                  // Signup Form
                  // ==================================================

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.055),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Name

                        _inputField(
                          controller: _nameController,
                          label: 'Your name',
                          icon: Icons.person_outline_rounded,
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // Account Type
                        //
                        // User أو Admin
                        // ==================================================

                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Account type',
                            labelStyle: GoogleFonts.dmSans(
                              color: const Color(0xFF96777D),
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.admin_panel_settings_outlined,
                              color: Color(0xFFB86F7B),
                              size: 21,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9F5F3),
                            contentPadding:
                            const EdgeInsets.symmetric(
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

                          items: [
                            DropdownMenuItem(
                              value: 'user',
                              child: Text(
                                'User',
                                style: GoogleFonts.dmSans(),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'admin',
                              child: Text(
                                'Admin',
                                style: GoogleFonts.dmSans(),
                              ),
                            ),
                          ],

                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),

                        const SizedBox(height: 14),

                        // Email

                        _inputField(
                          controller: _emailController,
                          label: 'Email address',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 14),

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

                        const SizedBox(height: 14),

                        // Confirm Password

                        _inputField(
                          controller: _confirmPasswordController,
                          label: 'Confirm password',
                          icon: Icons.verified_user_outlined,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF96777D),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // Create Account Button
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                            _isLoading ? null : _signup,
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
                              'Create my Bloom',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Your journey starts here  ✦',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF9B777E),
                      ),
                    ),
                  ),
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
      opacity: 0.12,
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