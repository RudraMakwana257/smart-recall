
enum QuizDifficulty {
  easy,
  medium,
  hard;

  static QuizDifficulty fromStrength(double strength) {
    if (strength < 40) return QuizDifficulty.easy;
    if (strength < 75) return QuizDifficulty.medium;
    return QuizDifficulty.hard;
  }
}

class QuizSession {
  final String deckId;
  List<String> cardIds;
  int currentIndex;
  int correctStreak;
  int incorrectStreak;
  QuizDifficulty currentDifficulty;
  Map<String, bool> results;
  DateTime startTime;

  QuizSession({
    required this.deckId,
    required this.cardIds,
    this.currentIndex = 0,
    this.correctStreak = 0,
    this.incorrectStreak = 0,
    this.currentDifficulty = QuizDifficulty.medium,
    Map<String, bool>? results,
    DateTime? startTime,
  })  : results = results ?? {},
        startTime = startTime ?? DateTime.now();

  bool get isComplete => currentIndex >= cardIds.length;

  double get score {
    if (results.isEmpty) return 0;
    final correct = results.values.where((v) => v).length;
    return (correct / results.length) * 100;
  }

  void recordAnswer(String cardId, bool isCorrect) {
    results[cardId] = isCorrect;

    if (isCorrect) {
      correctStreak++;
      incorrectStreak = 0;
      if (correctStreak >= 2) {
        _increaseDifficulty();
      }
    } else {
      incorrectStreak++;
      correctStreak = 0;
      if (incorrectStreak >= 2) {
        _decreaseDifficulty();
      }
    }
  }

  void _increaseDifficulty() {
    switch (currentDifficulty) {
      case QuizDifficulty.easy:
        currentDifficulty = QuizDifficulty.medium;
        break;
      case QuizDifficulty.medium:
        currentDifficulty = QuizDifficulty.hard;
        break;
      case QuizDifficulty.hard:
        // Already at maximum difficulty
        break;
    }
  }

  void _decreaseDifficulty() {
    switch (currentDifficulty) {
      case QuizDifficulty.hard:
        currentDifficulty = QuizDifficulty.medium;
        break;
      case QuizDifficulty.medium:
        currentDifficulty = QuizDifficulty.easy;
        break;
      case QuizDifficulty.easy:
        // Already at minimum difficulty
        break;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'cardIds': cardIds,
      'currentIndex': currentIndex,
      'correctStreak': correctStreak,
      'incorrectStreak': incorrectStreak,
      'currentDifficulty': currentDifficulty.index,
      'results': results.map((k, v) => MapEntry(k, v)),
      'startTime': startTime.toIso8601String(),
    };
  }

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      deckId: json['deckId'],
      cardIds: List<String>.from(json['cardIds']),
      currentIndex: json['currentIndex'],
      correctStreak: json['correctStreak'],
      incorrectStreak: json['incorrectStreak'],
      currentDifficulty: QuizDifficulty.values[json['currentDifficulty']],
      results: Map<String, bool>.from(json['results']),
      startTime: DateTime.parse(json['startTime']),
    );
  }
}

class QuizStats {
  final int totalQuizzes;
  final int totalQuestions;
  final int correctAnswers;
  final double averageScore;
  final Map<QuizDifficulty, int> difficultyDistribution;
  final Duration averageQuizDuration;

  QuizStats({
    required this.totalQuizzes,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.averageScore,
    required this.difficultyDistribution,
    required this.averageQuizDuration,
  });

  factory QuizStats.empty() {
    return QuizStats(
      totalQuizzes: 0,
      totalQuestions: 0,
      correctAnswers: 0,
      averageScore: 0,
      difficultyDistribution: {
        QuizDifficulty.easy: 0,
        QuizDifficulty.medium: 0,
        QuizDifficulty.hard: 0,
      },
      averageQuizDuration: Duration.zero,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuizzes': totalQuizzes,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'averageScore': averageScore,
      'difficultyDistribution':
          difficultyDistribution.map((k, v) => MapEntry(k.toString(), v)),
      'averageQuizDuration': averageQuizDuration.inSeconds,
    };
  }

  factory QuizStats.fromJson(Map<String, dynamic> json) {
    return QuizStats(
      totalQuizzes: json['totalQuizzes'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      averageScore: json['averageScore'],
      difficultyDistribution:
          (json['difficultyDistribution'] as Map).map((k, v) => MapEntry(
                QuizDifficulty.values.firstWhere((e) => e.toString() == k),
                v as int,
              )),
      averageQuizDuration: Duration(seconds: json['averageQuizDuration']),
    );
  }
}
