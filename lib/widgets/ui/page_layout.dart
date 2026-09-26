import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

// ============================================================
// Layout helpers
// ============================================================

double bloomPagePadding(double width) {
  if (width >= 900) return 40;
  if (width >= 600) return 28;
  return 20;
}

int bloomGridCount(double width) {
  if (width >= 1100) return 4;
  if (width >= 720) return 3;
  return 2;
}

void showBloomSnack(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.local_florist_rounded,
              size: 18,
              color: isError ? AppColors.coralSoft : AppColors.peach,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppText.sans(size: 13.5, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.forestDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
}
