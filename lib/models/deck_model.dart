// lib/models/deck_model.dart

class Flashcard {
  final String id;
  String question;
  String answer;
  String? hint;
  int reviewLevel;
  DateTime? lastReviewed;
  DateTime? nextReview;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.hint,
    this.reviewLevel = 0,
    this.lastReviewed,
    this.nextReview,
  });

  bool isDue() {
    if (nextReview == null) return true; // Never reviewed cards are always due
    return DateTime.now().isAfter(nextReview!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'hint': hint,
      'reviewLevel': reviewLevel,
      'lastReviewed': lastReviewed?.toIso8601String(),
      'nextReview': nextReview?.toIso8601String(),
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      hint: map['hint'],
      reviewLevel: map['reviewLevel'] ?? 0,
      lastReviewed: map['lastReviewed'] != null
          ? DateTime.tryParse(map['lastReviewed'])
          : null,
      nextReview: map['nextReview'] != null
          ? DateTime.tryParse(map['nextReview'])
          : null,
    );
  }
}

class Deck {
  final String id;
  String name;
  String description;
  List<String> tags;
  int cardCount;
  final DateTime createdAt;
  List<Flashcard> flashcards;

  Deck({
    required this.id,
    required this.name,
    this.description = '',
    this.tags = const [],
    this.cardCount = 0,
    required this.createdAt,
    this.flashcards = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
      'cardCount': cardCount,
      'createdAt': createdAt.toIso8601String(),
      'flashcards': flashcards.map((card) => card.toMap()).toList(),
    };
  }

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      tags: List<String>.from(map['tags']),
      cardCount: map['cardCount'],
      createdAt: DateTime.parse(map['createdAt']),
      flashcards: List<Flashcard>.from(
        map['flashcards']?.map((x) => Flashcard.fromMap(x)) ?? [],
      ),
    );
  }

  String get formattedDate {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  int get dueCardCount => flashcards.where((card) => card.isDue()).length;
}
