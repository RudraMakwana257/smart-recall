// lib/services/stats_service.dart
import '../models/stats_model.dart';

class StatsService {
  static LearningStats getMockStats() {
    return LearningStats(
      totalFlashcards: 128,
      totalDecks: 5,
      cardsReviewedToday: 12,
      masteredCards: 43,
      weeklyReviews: [
        DailyReview(date: DateTime.now().subtract(const Duration(days: 6)), count: 4),
        DailyReview(date: DateTime.now().subtract(const Duration(days: 5)), count: 9),
        DailyReview(date: DateTime.now().subtract(const Duration(days: 4)), count: 6),
        DailyReview(date: DateTime.now().subtract(const Duration(days: 3)), count: 10),
        DailyReview(date: DateTime.now().subtract(const Duration(days: 2)), count: 3),
        DailyReview(date: DateTime.now().subtract(const Duration(days: 1)), count: 0),
        DailyReview(date: DateTime.now(), count: 12),
      ],
      deckProgress: [
        DeckProgress(
          deckName: 'German Vocabulary',
          newCards: 14,
          learningCards: 18,
          reviewingCards: 22,
          masteredCards: 30,
        ),
        DeckProgress(
          deckName: 'JavaScript Basics',
          newCards: 9,
          learningCards: 7,
          reviewingCards: 6,
          masteredCards: 15,
        ),
      ],
      cardDistribution: CardDistribution(
        newPercent: 22,
        learningPercent: 30,
        reviewingPercent: 25,
        masteredPercent: 23,
      ),
      dailyGoal: DailyGoal(target: 10, completed: 12),
    );
  }
}