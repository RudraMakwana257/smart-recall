import '../models/deck_model.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

import '../services/deck/deck_actions.dart';

class DeckRepository extends ChangeNotifier {
  final List<Deck> _decks = [];

  List<Deck> get decks => List.unmodifiable(_decks);

  Future<void> init() async {
    // Load decks from storage
    final storedDecks = await DeckActions.getAllDecks();
    _decks.clear();
    _decks.addAll(storedDecks);
    notifyListeners();
  }

  Future<List<Deck>> getAllDecks() async {
    // Ensure we have the latest data
    final storedDecks = await DeckActions.getAllDecks();
    _decks.clear();
    _decks.addAll(storedDecks);
    return _decks;
  }

  Future<void> addDeck(Deck deck) async {
    await DeckActions.updateDeck(deck);
    _decks.add(deck);
    notifyListeners();
  }

  Future<void> updateDeck(Deck deck) async {
    final index = _decks.indexWhere((d) => d.id == deck.id);
    if (index != -1) {
      _decks[index] = deck;
      await DeckActions.updateDeck(deck);
      notifyListeners();
    }
  }

  Future<void> deleteDeck(String id) async {
    _decks.removeWhere((deck) => deck.id == id);
    await DeckActions.deleteDeck(id);
    notifyListeners();
  }

  Future<void> clearAllDecks() async {
    for (final deck in _decks) {
      await DeckActions.deleteDeck(deck.id);
    }
    _decks.clear();
    notifyListeners();
  }

  Future<Deck?> getDeck(String id) async {
    return _decks.firstWhere((deck) => deck.id == id);
  }

  Future<Deck> createDeck({
    required String name,
    String description = '',
    List<String> tags = const [],
  }) async {
    // Create the deck using DeckActions
    final newDeck = await DeckActions.createDeck(
      name: name,
      description: description,
      tags: tags,
    );

    // Add the new deck to our local list
    _decks.add(newDeck);
    notifyListeners();

    return newDeck;
  }

  Future<void> addFlashcard(String deckId, Flashcard flashcard) async {
    await DeckActions.addFlashcard(deckId, flashcard);
    // Refresh our local list
    await getAllDecks();
  }
}

// // lib/repositories/deck_repository.dart
// import 'package:flutter/foundation.dart';
// import '../models/deck_model.dart';
//
// class DeckRepository {
//   final List<Deck> _decks = [];
//
//   // Get all decks
//   Future<List<Deck>> getAllDecks() async {
//     await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
//     return _decks;
//   }
//
//   // Create new deck
//   Future<Deck> createDeck({
//     required String name,
//     String description = '',
//     List<String> tags = const [],
//   }) async {
//     final newDeck = Deck(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       name: name,
//       description: description,
//       tags: tags,
//       createdAt: DateTime.now(),
//     );
//     _decks.add(newDeck);
//     return newDeck;
//   }
//
//   // Update deck
//   Future<void> updateDeck(Deck deck) async {
//     final index = _decks.indexWhere((d) => d.id == deck.id);
//     if (index != -1) {
//       _decks[index] = deck;
//     }
//   }
//
//   // Delete deck
//   Future<void> deleteDeck(String deckId) async {
//     _decks.removeWhere((deck) => deck.id == deckId);
//   }
//
//   // Add cards to deck
//   Future<void> addFlashcard(String deckId, Flashcard flashcard) async {
//     final index = _decks.indexWhere((deck) => deck.id == deckId);
//     if (index == -1) {
//       throw Exception('Deck not found');
//     }
//     _decks[index].flashcards.add(flashcard);
//     _decks[index].cardCount = _decks[index].flashcards.length;
//
//     await Future.delayed(const Duration(milliseconds: 500)); // simulate saving delay
//   }
// }
