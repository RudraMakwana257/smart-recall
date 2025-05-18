import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../models/deck_model.dart';
import 'storage_interface.dart';
import 'storage_selector.dart';

class DeckActions {
  static const String _storageKey = 'flashcard_decks';
  static final DeckStorage _storage = getStorage();

  static Future<Deck> createDeck({
    required String name,
    String description = '',
    List<String> tags = const [],
  }) async {
    final newDeck = Deck(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      tags: tags,
      createdAt: DateTime.now(),
    );

    final decks = await getAllDecks();
    decks.insert(0, newDeck);
    await _saveDecks(decks);
    return newDeck;
  }

  static Future<List<Deck>> getAllDecks() async {
    try {
      final decksJson = await _storage.read(_storageKey);
      if (decksJson == null || decksJson.isEmpty) return [];

      final List<dynamic> decoded = json.decode(decksJson);
      return decoded.map((item) => Deck.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Failed to decode decks: $e');
      return [];
    }
  }

  static Future<void> updateDeck(Deck updatedDeck) async {
    final decks = await getAllDecks();
    final index = decks.indexWhere((deck) => deck.id == updatedDeck.id);
    if (index != -1) {
      decks[index] = updatedDeck;
      await _saveDecks(decks);
    }
  }

  static Future<void> deleteDeck(String deckId) async {
    final decks = await getAllDecks();
    decks.removeWhere((deck) => deck.id == deckId);
    await _saveDecks(decks);
  }

  static Future<void> addFlashcard(String deckId, Flashcard flashcard) async {
    final decks = await getAllDecks();
    final index = decks.indexWhere((deck) => deck.id == deckId);
    if (index == -1) throw Exception('Deck not found');

    decks[index].flashcards.add(flashcard);
    decks[index].cardCount = decks[index].flashcards.length;
    await updateDeck(decks[index]);
  }

  static Future<void> removeFlashcard(String deckId, String flashcardId) async {
    final decks = await getAllDecks();
    final index = decks.indexWhere((deck) => deck.id == deckId);
    if (index == -1) throw Exception('Deck not found');

    decks[index].flashcards.removeWhere((card) => card.id == flashcardId);
    decks[index].cardCount = decks[index].flashcards.length;
    await updateDeck(decks[index]);
  }

  static Future<void> _saveDecks(List<Deck> decks) async {
    try {
      final encoded = json.encode(decks.map((deck) => deck.toMap()).toList());
      await _storage.write(_storageKey, encoded);
    } catch (e) {
      debugPrint('Failed to save decks: $e');
      rethrow;
    }
  }

  static String formatDeckDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
