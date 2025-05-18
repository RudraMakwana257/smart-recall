// lib/widgets/deck_progress_card.dart
import 'package:flutter/material.dart';
import '../models/stats_model.dart';

class DeckProgressCard extends StatelessWidget {
  final DeckProgress progress;

  const DeckProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🗂️ ${progress.deckName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressItem('📄 New', progress.newCards),
                _buildProgressItem('🔁 Learning', progress.learningCards),
                _buildProgressItem('📘 Reviewing', progress.reviewingCards),
                _buildProgressItem('🧠 Mastered', progress.masteredCards),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, int count) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}