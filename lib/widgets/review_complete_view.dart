// lib/widgets/review_complete_view.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ReviewCompleteView extends StatelessWidget {
  final VoidCallback onReturnToDeck;

  const ReviewCompleteView({
    super.key,
    required this.onReturnToDeck,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkBlueGradient.scale(0.15)
              : AppTheme.primaryGradient.scale(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow:
              isDarkMode ? AppTheme.darkModeShadows : AppTheme.lightModeShadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? AppTheme.darkBlueGradient
                    : AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                size: 48,
                color: isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'All Done for Today! 🎉',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : theme.textTheme.headlineMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve completed all your reviews.\nCome back tomorrow for more practice!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : theme.textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onReturnToDeck,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: isDarkMode
                    ? AppTheme.darkPrimaryBlue
                    : AppTheme.primaryBlue,
                foregroundColor:
                    isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
              ),
              icon: const Icon(Icons.arrow_back),
              label: Text(
                'Back to Deck',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
