import 'package:flutter/material.dart';
import 'app_theme.dart';

class ToastUtils {
  static void showToast({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (isError)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.error_outline,
                color: isDarkMode ? theme.colorScheme.error : Colors.white,
                size: 20,
              ),
            ),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError
          ? (isDarkMode
              ? theme.colorScheme.error.withOpacity(0.8)
              : theme.colorScheme.error)
          : (isDarkMode
              ? AppTheme.darkPrimaryBlue
              : AppTheme.primaryBlue),
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccessToast({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final snackBar = SnackBar(
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.green[800]
                  : Colors.green[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: isDarkMode ? Colors.green[100] : Colors.green[800],
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isDarkMode
          ? const Color(0xFF1B5E20) // Dark green
          : const Color(0xFF2E7D32), // Light green
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
} 