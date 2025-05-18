// lib/widgets/review_controls.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class ReviewControls extends StatelessWidget {
  final VoidCallback onBackToDeck;
  final VoidCallback onSkipCard;
  final VoidCallback onResetSession;

  const ReviewControls({
    super.key,
    required this.onBackToDeck,
    required this.onSkipCard,
    required this.onResetSession,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppTheme.darkSecondaryBackground
            : AppTheme.lightBackground,
        boxShadow:
            isDarkMode ? AppTheme.darkModeShadows : AppTheme.lightModeShadows,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildControlButton(
            context: context,
            onPressed: onBackToDeck,
            icon: Icons.arrow_back,
            label: 'Back to Deck',
            isDarkMode: isDarkMode,
          ),
          _buildControlButton(
            context: context,
            onPressed: onSkipCard,
            icon: Icons.skip_next,
            label: 'Skip Card',
            isDarkMode: isDarkMode,
          ),
          _buildControlButton(
            context: context,
            onPressed: onResetSession,
            icon: Icons.refresh,
            label: 'Reset',
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isDarkMode,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
        backgroundColor: isDarkMode
            ? AppTheme.darkPrimaryBlue.withOpacity(0.1)
            : AppTheme.primaryBlue.withOpacity(0.1),
      ),
      icon: Icon(
        icon,
        size: 20,
        color: isDarkMode ? AppTheme.darkPrimaryBlue : AppTheme.primaryBlue,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: AppTheme.bodySmall,
          color: isDarkMode ? AppTheme.darkPrimaryBlue : AppTheme.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
