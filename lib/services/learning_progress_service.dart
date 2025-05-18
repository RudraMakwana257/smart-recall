import 'package:flutter/foundation.dart';
import 'srs_service.dart';
import 'quiz_service.dart';

class LearningProgressService extends ChangeNotifier {
  final SRSService _srsService;
  final QuizService _quizService;

  LearningProgressService(this._srsService, this._quizService);

  // Get daily review counts for the last 7 days
  List<DailyProgress> getWeeklyProgress() {
    final now = DateTime.now();
    final List<DailyProgress> weeklyProgress = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final reviewCount = _getDailyReviewCount(date);
      weeklyProgress.add(DailyProgress(date: date, count: reviewCount));
    }

    return weeklyProgress;
  }

  // Get current learning streak
  int getCurrentStreak() {
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0;; i++) {
      final date = now.subtract(Duration(days: i));
      final reviewCount = _getDailyReviewCount(date);

      if (reviewCount > 0) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Get mastery distribution
  Map<String, double> getMasteryDistribution() {
    final stats = _srsService.getReviewStats();
    final total = stats['totalCards'] as int;

    if (total == 0) {
      return {
        'New': 0,
        'Learning': 0,
        'Mastered': 0,
      };
    }

    return {
      'New': (stats['newCards'] as int) / total * 100,
      'Learning': (stats['learningCards'] as int) / total * 100,
      'Mastered': (stats['masteredCards'] as int) / total * 100,
    };
  }

  // Get quiz performance data
  Map<String, dynamic> getQuizPerformance() {
    final quizStats = _quizService.stats;
    return {
      'totalQuizzes': quizStats.totalQuizzes,
      'averageScore': quizStats.averageScore,
      'correctAnswers': quizStats.correctAnswers,
      'totalQuestions': quizStats.totalQuestions,
      'averageDuration': quizStats.averageQuizDuration,
      'difficultyDistribution': quizStats.difficultyDistribution,
    };
  }

  // Private helper method to get review count for a specific date
  int _getDailyReviewCount(DateTime date) {
    return _srsService.getReviewStats()['cardsReviewedToday'] as int;
  }
}

class DailyProgress {
  final DateTime date;
  final int count;

  DailyProgress({required this.date, required this.count});
}
