// lib/widgets/review_header.dart
import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../utils/app_theme.dart';

class ReviewHeader extends StatelessWidget {
  final Deck deck;
  final int dueCardsCount;

  const ReviewHeader({
    super.key,
    required this.deck,
    required this.dueCardsCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? AppTheme.darkBlueGradient.scale(0.15)
            : AppTheme.primaryGradient.scale(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow:
            isDarkMode ? AppTheme.darkModeShadows : AppTheme.lightModeShadows,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? AppTheme.darkBlueGradient
                      : AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.library_books,
                  color: isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${deck.cardCount} cards total',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppTheme.darkTextSecondary
                            : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppTheme.darkCardBackground.withOpacity(0.5)
                  : AppTheme.lightCardBackground.withOpacity(0.9),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(
                color: isDarkMode
                    ? AppTheme.darkPrimaryBlue.withOpacity(0.2)
                    : AppTheme.primaryBlue.withOpacity(0.2),
              ),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppTheme.darkPrimaryBlue.withOpacity(0.1)
                            : AppTheme.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isDarkMode
                            ? AppTheme.darkPrimaryBlue
                            : AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
            Text(
                      'Due Today',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppTheme.darkTextPrimary
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: isDarkMode
                        ? AppTheme.darkBlueGradient.scale(0.2)
                        : AppTheme.primaryGradient.scale(0.2),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Text(
                    dueCardsCount.toString(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode
                          ? AppTheme.darkTextPrimary
                          : AppTheme.lightBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ],
        ),
          ),
        ],
      ),
    );
  }
}
