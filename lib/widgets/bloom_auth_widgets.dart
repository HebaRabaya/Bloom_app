import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The exact floral background from the design image, used full-screen.
class AuthDecorBackground extends StatelessWidget {
  final Widget child;

  const AuthDecorBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Color(0xFFF8EDE6)),
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              AppAssets.authScreenBackground,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// Keeps auth content in the open pink middle of the floral frame:
/// below the top roses and above the bottom roses, with even spacing.
class AuthScreenFrame extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Widget footer;

  const AuthScreenFrame({
    super.key,
    required this.header,
    required this.body,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height;
    final keyboard = media.viewInsets.bottom;
    final topPad = media.padding.top + height * 0.10;
    final bottomPad = media.padding.bottom + height * 0.08;

    return Padding(
      padding: EdgeInsets.fromLTRB(28, topPad, 28, bottomPad),
      child: Column(
        children: [
          header,
          SizedBox(height: height * 0.02),
          Expanded(
            child: SingleChildScrollView(
              clipBehavior: Clip.none,
              padding: EdgeInsets.only(bottom: keyboard > 0 ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  body,
                  SizedBox(height: height * 0.03),
                  footer,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSubmitted,
  });

  static const _radius = 14.0;

  OutlineInputBorder _border([double width = 1.05]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: AppColors.authFieldBorder, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      onSubmitted: onSubmitted,
      style: AppText.serif(size: 16, weight: FontWeight.w500, color: AppColors.authInk),
      cursorColor: AppColors.authForest,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.serif(
          size: 16,
          weight: FontWeight.w400,
          color: AppColors.authMuted,
          style: FontStyle.italic,
        ),
        filled: true,
        fillColor: AppColors.authFieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: Icon(icon, size: 20, color: AppColors.authInk),
        suffixIcon: suffix,
        prefixIconColor: AppColors.authInk,
        suffixIconColor: AppColors.authMuted,
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(1.35),
        errorBorder: _border(),
        focusedErrorBorder: _border(1.35),
      ),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.authForest,
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const CustomPaint(painter: _SilkTexturePainter()),
                  Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            label,
                            style: AppText.serif(
                              size: 20,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SilkTexturePainter extends CustomPainter {
  const _SilkTexturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = const Color(0x22FFFFFF);
    final dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..color = const Color(0x24000000);

    for (var i = -3; i < 12; i++) {
      final path = Path();
      final y = 10.0 * i;
      path.moveTo(-40, y);
      for (double x = 0; x <= size.width + 50; x += 6) {
        path.lineTo(
          x,
          y + math.sin((x / size.width) * math.pi * 2.6 + i * 0.55) * 9,
        );
      }
      canvas.drawPath(path, i.isEven ? light : dark);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthDivider extends StatelessWidget {
  final String label;

  const AuthDivider({super.key, this.label = 'or'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD8CEC4), height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: AppText.sans(size: 12.5, color: AppColors.authMuted),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD8CEC4), height: 1)),
      ],
    );
  }
}

class AuthSocialRow extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  const AuthSocialRow({
    super.key,
    required this.onGoogle,
    required this.onApple,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SocialCircleButton(
            onTap: onGoogle,
            child: const CustomPaint(
              size: Size(22, 22),
              painter: _GoogleGPainter(),
            ),
          ),
          const SizedBox(width: 16),
          _SocialCircleButton(
            onTap: onApple,
            child: const Icon(Icons.apple, size: 26, color: Color(0xFF3A3A3A)),
          ),
        ],
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SocialCircleButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x33000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    void arc(Color color, double start, double sweep) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt,
      );
    }

    arc(const Color(0xFFEA4335), 3.85, 1.55);
    arc(const Color(0xFFFBBC05), 0.55, 1.15);
    arc(const Color(0xFF34A853), 1.7, 1.35);
    arc(const Color(0xFF4285F4), -0.55, 1.15);

    canvas.drawRRect(
      RRect.fromLTRBR(
        size.width * 0.48,
        size.height * 0.42,
        size.width - stroke * 0.15,
        size.height * 0.58,
        const Radius.circular(1),
      ),
      Paint()..color = const Color(0xFF4285F4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String action;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text.rich(
          TextSpan(
            text: prompt,
            style: AppText.serif(size: 15, color: AppColors.authInk),
            children: [
              TextSpan(
                text: action,
                style: AppText.serif(
                  size: 15,
                  weight: FontWeight.w700,
                  color: AppColors.authTerracotta,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
