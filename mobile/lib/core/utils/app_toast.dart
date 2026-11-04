import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppToast {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = true,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final topPadding = MediaQuery.of(context).padding.top;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -40.0, end: 0.0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: Opacity(
                  opacity: (1.0 + (value / 40.0)).clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isError
                    ? AppColors.error
                    : (isSuccess ? AppColors.primary : AppColors.textPrimary),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isError
                        ? Icons.error_outline_rounded
                        : (isSuccess ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

    overlay.insert(entry);

    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }

  static void success(BuildContext context, String message) {
    show(context, message, isSuccess: true, isError: false);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isSuccess: false, isError: true);
  }

  static void info(BuildContext context, String message) {
    show(context, message, isSuccess: false, isError: false);
  }
}
