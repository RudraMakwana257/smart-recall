// lib/services/review_service.dart
import '../models/deck_model.dart';

class ReviewService {
  static const int maxDueCards =
      5; // Maximum number of cards per review session

  static List<Flashcard> getDueFlashcards(Deck deck) {
    // Return all flashcards in random order
    final allCards = List<Flashcard>.from(deck.flashcards);
    allCards.shuffle();
    return allCards;
  }

  static Duration getReviewInterval(int level) {
    switch (level) {
      case 0:
        return const Duration(minutes: 1); // New
      case 1:
        return const Duration(days: 1); // Learning
      case 2:
        return const Duration(days: 3); // Reviewing
      case 3:
        return const Duration(days: 7); // Mastered
      default:
        return const Duration(days: 1);
    }
  }

  static Flashcard processReviewResponse(Flashcard card, int quality) {
    final now = DateTime.now();
    final updatedCard = Flashcard(
      id: card.id,
      question: card.question,
      answer: card.answer,
      hint: card.hint,
      reviewLevel: card.reviewLevel,
      lastReviewed: now,
      nextReview: now,
    );

    switch (quality) {
      case 0: // Again
        updatedCard.reviewLevel = 0;
        break;
      case 1: // Good
        updatedCard.reviewLevel = (card.reviewLevel + 1).clamp(0, 3);
        break;
      case 2: // Easy
        updatedCard.reviewLevel = (card.reviewLevel + 2).clamp(0, 3);
        break;
    }

    updatedCard.nextReview =
        now.add(getReviewInterval(updatedCard.reviewLevel));
    return updatedCard;
  }

  static DateTime getNextReviewTime(Flashcard card) {
    return card.nextReview ??
        DateTime.now().add(getReviewInterval(card.reviewLevel));
  }
}
