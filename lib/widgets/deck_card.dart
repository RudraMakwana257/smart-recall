// lib/widgets/deck_card.dart
import 'package:flutter/material.dart';
import '../../models/deck_model.dart';

class DeckCard extends StatelessWidget {
  final Deck deck;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(Deck) onAddCards;
  final Function(Deck) onReview;

  const DeckCard({
    super.key,
    required this.deck,
    required this.onEdit,
    required this.onDelete,
    required this.onAddCards,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    deck.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                ),
              ],
            ),
            if (deck.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(deck.description),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.collections_bookmark, size: 16),
                const SizedBox(width: 4),
                Text('${deck.cardCount} flashcards'),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(deck.formattedDate),
              ],
            ),
            if (deck.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: deck.tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: Colors.grey[200],
                ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Cards'),
                    onPressed:() => onAddCards(deck),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Review'),
                    onPressed: () => onReview(deck),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}