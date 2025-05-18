import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_data.dart';
import '../models/card_review_data.dart';
import 'srs_service.dart';
import 'dart:convert';

class QuizService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final SRSService _srsService;
  static const String _quizStatsKey = 'quiz_stats';
  static const String _activeQuizKey = 'active_quiz';

  QuizSession? _activeSession;
  QuizStats _stats;

  QuizService(this._prefs, this._srsService) : _stats = QuizStats.empty() {
    _loadStats();
    _loadActiveSession();
  }

  QuizSession? get activeSession => _activeSession;
  QuizStats get stats => _stats;

  void _loadStats() {
    try {
    final String? jsonStr = _prefs.getString(_quizStatsKey);
    if (jsonStr != null) {
      _stats = QuizStats.fromJson(json.decode(jsonStr));
      } else {
        _stats = QuizStats.empty();
      }
      notifyListeners();
    } catch (e) {
      print('Error loading quiz stats: $e');
      _stats = QuizStats.empty();
      notifyListeners();
    }
  }

  void _loadActiveSession() {
    try {
    final String? jsonStr = _prefs.getString(_activeQuizKey);
    if (jsonStr != null) {
      _activeSession = QuizSession.fromJson(json.decode(jsonStr));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading active session: $e');
      _activeSession = null;
      notifyListeners();
    }
  }

  Future<void> _saveStats() async {
    try {
    await _prefs.setString(_quizStatsKey, json.encode(_stats.toJson()));
    notifyListeners();
    } catch (e) {
      print('Error saving quiz stats: $e');
    }
  }

  Future<void> _saveActiveSession() async {
    try {
    if (_activeSession != null) {
      await _prefs.setString(
          _activeQuizKey, json.encode(_activeSession!.toJson()));
    } else {
      await _prefs.remove(_activeQuizKey);
    }
    notifyListeners();
    } catch (e) {
      print('Error saving active session: $e');
    }
  }

  // Start a new quiz session for a deck
  Future<QuizSession> startQuiz(String deckId, List<String> cardIds) async {
    // End any existing session
    if (_activeSession != null) {
      await endQuiz();
    }

    // Sort cards by difficulty based on memory strength
    cardIds.sort((a, b) {
      final strengthA = _srsService.getMemoryStrength(a);
      final strengthB = _srsService.getMemoryStrength(b);
      return strengthA.compareTo(strengthB);
    });

    _activeSession = QuizSession(
      deckId: deckId,
      cardIds: cardIds,
      currentDifficulty: QuizDifficulty.medium,
    );

    await _saveActiveSession();
    return _activeSession!;
  }

  // Record an answer and update difficulty
  Future<void> recordAnswer(String cardId, bool isCorrect) async {
    if (_activeSession == null) return;

    _activeSession!.recordAnswer(cardId, isCorrect);
    _activeSession!.currentIndex++;

    // Update SRS data based on quiz performance
    if (isCorrect) {
      await _srsService.processReview(
        cardId,
        _activeSession!.currentDifficulty == QuizDifficulty.hard
            ? ReviewGrade.easy
            : ReviewGrade.good,
      );
    } else {
      await _srsService.processReview(cardId, ReviewGrade.again);
    }

    await _saveActiveSession();

    // End quiz if complete
    if (_activeSession!.isComplete) {
      await endQuiz();
    }
  }

  // End the current quiz session and update statistics
  Future<void> endQuiz() async {
    if (_activeSession == null) return;

    final session = _activeSession!;
    final duration = DateTime.now().difference(session.startTime);

    // Update statistics
    _stats = QuizStats(
      totalQuizzes: _stats.totalQuizzes + 1,
      totalQuestions: _stats.totalQuestions + session.results.length,
      correctAnswers:
          _stats.correctAnswers + session.results.values.where((v) => v).length,
      averageScore:
          (_stats.averageScore * _stats.totalQuizzes + session.score) /
              (_stats.totalQuizzes + 1),
      difficultyDistribution: {
        for (var difficulty in QuizDifficulty.values)
          difficulty: (_stats.difficultyDistribution[difficulty] ?? 0) +
              (session.currentDifficulty == difficulty ? 1 : 0),
      },
      averageQuizDuration: Duration(
        milliseconds:
            ((_stats.averageQuizDuration.inMilliseconds * _stats.totalQuizzes +
                        duration.inMilliseconds) /
                    (_stats.totalQuizzes + 1))
                .round(),
      ),
    );

    _activeSession = null;
    await _saveStats();
    await _saveActiveSession();
  }

  // Get recommended difficulty for a card based on memory strength
  QuizDifficulty getRecommendedDifficulty(String cardId) {
    final strength = _srsService.getMemoryStrength(cardId);
    return QuizDifficulty.fromStrength(strength);
  }

  // Reset quiz statistics
  Future<void> resetStats() async {
    _stats = QuizStats.empty();
    await _saveStats();
  }

  // Abandon the current quiz session
  Future<void> abandonQuiz() async {
    _activeSession = null;
    await _saveActiveSession();
  }
}
