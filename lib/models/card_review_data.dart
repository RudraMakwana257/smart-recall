import 'dart:math' show pow, e, log;

enum ReviewGrade {
  again(0), // Failed to recall - reset interval
  hard(1), // Difficult recall - smaller interval increase
  good(2), // Successful recall - normal interval increase
  easy(3); // Perfect recall - larger interval increase

  final int value;
  const ReviewGrade(this.value);
}

class CardReviewData {
  final String cardId;
  DateTime lastReviewDate;
  DateTime nextReviewDate;
  int intervalDays;
  double easeFactor;
  int consecutiveCorrect;
  List<ReviewGrade> reviewHistory;

  CardReviewData({
    required this.cardId,
    DateTime? lastReviewDate,
    DateTime? nextReviewDate,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
    this.consecutiveCorrect = 0,
    List<ReviewGrade>? reviewHistory,
  })  : lastReviewDate = lastReviewDate ?? DateTime.now(),
        nextReviewDate = nextReviewDate ?? DateTime.now(),
        reviewHistory = reviewHistory ?? [];

  // Calculate next review interval based on SuperMemo 2 algorithm
  void processReview(ReviewGrade grade) {
    lastReviewDate = DateTime.now();
    reviewHistory.add(grade);

    switch (grade) {
      case ReviewGrade.again:
        intervalDays = 1;
        consecutiveCorrect = 0;
        easeFactor = max(1.3, easeFactor - 0.2);
        break;

      case ReviewGrade.hard:
        if (intervalDays == 0) {
          intervalDays = 1;
        } else {
          intervalDays = (intervalDays * 1.2).round();
        }
        consecutiveCorrect++;
        easeFactor = max(1.3, easeFactor - 0.15);
        break;

      case ReviewGrade.good:
        if (intervalDays == 0) {
          intervalDays = 1;
        } else {
          intervalDays = (intervalDays * easeFactor).round();
        }
        consecutiveCorrect++;
        break;

      case ReviewGrade.easy:
        if (intervalDays == 0) {
          intervalDays = 4;
        } else {
          intervalDays = (intervalDays * easeFactor * 1.3).round();
        }
        consecutiveCorrect++;
        easeFactor = min(3.0, easeFactor + 0.15);
        break;
    }

    // Cap maximum interval at 365 days
    intervalDays = min(365.0, intervalDays.toDouble()).toInt();

    nextReviewDate = DateTime.now().add(Duration(days: intervalDays));
  }

  // Get memory strength percentage (0-100)
  double getMemoryStrength() {
    if (reviewHistory.isEmpty) return 0;

    final daysSinceLastReview =
        DateTime.now().difference(lastReviewDate).inDays;
    final progress = daysSinceLastReview / intervalDays;

    // Exponential decay formula
    return (100 * pow(e, -progress * log(2))).toDouble();
  }

  // Check if card is due for review
  bool isDue() {
    return DateTime.now().isAfter(nextReviewDate);
  }

  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'lastReviewDate': lastReviewDate.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
      'consecutiveCorrect': consecutiveCorrect,
      'reviewHistory': reviewHistory.map((grade) => grade.value).toList(),
    };
  }

  factory CardReviewData.fromJson(Map<String, dynamic> json) {
    return CardReviewData(
      cardId: json['cardId'],
      lastReviewDate: DateTime.parse(json['lastReviewDate']),
      nextReviewDate: DateTime.parse(json['nextReviewDate']),
      intervalDays: json['intervalDays'],
      easeFactor: json['easeFactor'],
      consecutiveCorrect: json['consecutiveCorrect'],
      reviewHistory: (json['reviewHistory'] as List)
          .map((value) => ReviewGrade.values[value as int])
          .toList(),
    );
  }

  double max(double a, double b) => a > b ? a : b;
  double min(double a, double b) => a < b ? a : b;
}
