import 'package:flutter/material.dart';
import '../../models/deck_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/page_transitions.dart';
import '../../screens/add_flashcards_screen.dart';
import '../../screens/review_screen.dart';

class DeckGrid extends StatelessWidget {
  final List<Deck> decks;
  final VoidCallback onCreateDeck;
  final Function(Deck) onReview;
  final Function(Deck) onEdit;
  final Function(Deck) onDelete;

  const DeckGrid({
    super.key,
    required this.decks,
    required this.onCreateDeck,
    required this.onReview,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (decks.isEmpty) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      final theme = Theme.of(context);

      return SliverToBoxAdapter(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isDarkMode
                  ? AppTheme.darkBlueGradient.scale(0.15)
                  : AppTheme.primaryGradient.scale(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              boxShadow: isDarkMode
                  ? AppTheme.darkModeShadows
                  : AppTheme.lightModeShadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: isDarkMode
                        ? AppTheme.darkBlueGradient
                        : AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.library_add_outlined,
                    size: 32,
                    color: isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No decks created yet',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? AppTheme.darkTextPrimary
                        : theme.textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start by creating your first deck!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDarkMode
                        ? AppTheme.darkTextSecondary
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onCreateDeck,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Deck'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? AppTheme.darkPrimaryBlue
                        : AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final deck = decks[index];
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

          return GestureDetector(
            onTap: () => onReview(deck),
            child: Container(
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? AppTheme.darkBlueGradient.scale(0.15)
                    : AppTheme.primaryGradient.scale(0.1),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                boxShadow: isDarkMode
                    ? AppTheme.darkModeShadows
                    : AppTheme.lightModeShadows,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    deck.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${deck.flashcards.length} cards',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppTheme.darkTextSecondary
                              : Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEdit(deck),
                        tooltip: 'Edit Deck',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onDelete(deck),
                        tooltip: 'Delete Deck',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        childCount: decks.length,
      ),
    );
  }
}
