// lib/models/stats_model.dart
class LearningStats {
  final int totalFlashcards;
  final int totalDecks;
  final int cardsReviewedToday;
  final int masteredCards;
  final List<DailyReview> weeklyReviews;
  final List<DeckProgress> deckProgress;
  final CardDistribution cardDistribution;
  final DailyGoal dailyGoal;

  LearningStats({
    required this.totalFlashcards,
    required this.totalDecks,
    required this.cardsReviewedToday,
    required this.masteredCards,
    required this.weeklyReviews,
    required this.deckProgress,
    required this.cardDistribution,
    required this.dailyGoal,
  });
}

class DailyReview {
  final DateTime date;
  final int count;

  DailyReview({required this.date, required this.count});
}

class DeckProgress {
  final String deckName;
  final int newCards;
  final int learningCards;
  final int reviewingCards;
  final int masteredCards;

  DeckProgress({
    required this.deckName,
    required this.newCards,
    required this.learningCards,
    required this.reviewingCards,
    required this.masteredCards,
  });
}

class CardDistribution {
  final double newPercent;
  final double learningPercent;
  final double reviewingPercent;
  final double masteredPercent;

  CardDistribution({
    required this.newPercent,
    required this.learningPercent,
    required this.reviewingPercent,
    required this.masteredPercent,
  });
}

class DailyGoal {
  final int target;
  final int completed;

  DailyGoal({required this.target, required this.completed});
}