import 'package:flutter/foundation.dart';
import '../models/card_review_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SRSService extends ChangeNotifier {
  final SharedPreferences _prefs;
  final Map<String, CardReviewData> _reviewData = {};
  static const String _reviewDataKey = 'review_data';

  SRSService(this._prefs) {
    _loadReviewData();
  }

  // Load review data from persistent storage
  void _loadReviewData() {
    final String? jsonStr = _prefs.getString(_reviewDataKey);
    if (jsonStr != null) {
      final Map<String, dynamic> jsonMap = json.decode(jsonStr);
      jsonMap.forEach((cardId, data) {
        _reviewData[cardId] = CardReviewData.fromJson(data);
      });
    }
    notifyListeners();
  }

  // Save review data to persistent storage
  Future<void> _saveReviewData() async {
    final Map<String, dynamic> jsonMap = {};
    _reviewData.forEach((cardId, data) {
      jsonMap[cardId] = data.toJson();
    });
    await _prefs.setString(_reviewDataKey, json.encode(jsonMap));
    notifyListeners();
  }

  // Get review data for a card
  CardReviewData getCardReviewData(String cardId) {
    return _reviewData[cardId] ?? CardReviewData(cardId: cardId);
  }

  // Process a review for a card
  Future<void> processReview(String cardId, ReviewGrade grade) async {
    final reviewData = getCardReviewData(cardId);
    reviewData.processReview(grade);
    _reviewData[cardId] = reviewData;
    await _saveReviewData();
  }

  // Get all due cards
  List<String> getDueCards() {
    return _reviewData.entries
        .where((entry) => entry.value.isDue())
        .map((entry) => entry.key)
        .toList();
  }

  // Get cards due today
  List<String> getCardsForToday() {
    final now = DateTime.now();
    return _reviewData.entries
        .where((entry) {
          final nextReview = entry.value.nextReviewDate;
          return nextReview.year == now.year &&
              nextReview.month == now.month &&
              nextReview.day == now.day;
        })
        .map((entry) => entry.key)
        .toList();
  }

  // Get memory strength for a card
  double getMemoryStrength(String cardId) {
    return getCardReviewData(cardId).getMemoryStrength();
  }

  // Get review statistics
  Map<String, dynamic> getReviewStats() {
    if (_reviewData.isEmpty) {
      return {
        'totalCards': 0,
        'dueCards': 0,
        'masteredCards': 0,
        'learningCards': 0,
        'newCards': 0,
        'averageStrength': 0.0,
        'cardsReviewedToday': 0,
      };
    }

    final now = DateTime.now();
    int dueCards = 0;
    int masteredCards = 0;
    int learningCards = 0;
    int newCards = 0;
    double totalStrength = 0;
    int cardsReviewedToday = 0;

    for (var data in _reviewData.values) {
      final strength = data.getMemoryStrength();
      totalStrength += strength;

      if (data.isDue()) {
        dueCards++;
      }

      if (data.reviewHistory.isEmpty) {
        newCards++;
      } else if (strength >= 80) {
        masteredCards++;
      } else {
        learningCards++;
      }

      // Count cards reviewed today
      if (data.lastReviewDate.year == now.year &&
          data.lastReviewDate.month == now.month &&
          data.lastReviewDate.day == now.day) {
        cardsReviewedToday++;
      }
    }

    return {
      'totalCards': _reviewData.length,
      'dueCards': dueCards,
      'masteredCards': masteredCards,
      'learningCards': learningCards,
      'newCards': newCards,
      'averageStrength': totalStrength / _reviewData.length,
      'cardsReviewedToday': cardsReviewedToday,
    };
  }

  // Reset review data for a card
  Future<void> resetCard(String cardId) async {
    _reviewData[cardId] = CardReviewData(cardId: cardId);
    await _saveReviewData();
  }

  // Delete review data for a card
  Future<void> deleteCard(String cardId) async {
    _reviewData.remove(cardId);
    await _saveReviewData();
  }

  Future<void> clearAllData() async {
    _reviewData.clear();
    await _prefs.remove(_reviewDataKey);
    notifyListeners();
  }
}
