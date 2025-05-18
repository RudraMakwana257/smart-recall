// lib/screens/review_screen.dart
import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../repositories/deck_repository.dart';
import '../services/review_service.dart';
import '../widgets/flashcard_viewer.dart';
import '../widgets/review_complete_view.dart';
import '../widgets/review_header.dart';
import '../widgets/review_controls.dart';
import '../utils/app_theme.dart';

class ReviewScreen extends StatefulWidget {
  final Deck deck;

  const ReviewScreen({super.key, required this.deck});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  final DeckRepository _deckRepository = DeckRepository();
  List<Flashcard> _dueCards = [];
  int _currentCardIndex = 0;
  bool _showAnswer = false;
  bool _sessionComplete = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    print('ReviewScreen initialized with deck: ${widget.deck.name}');
    print('Deck ID: ${widget.deck.id}');
    print('Flashcards count: ${widget.deck.flashcards.length}');

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_progressController);

    _initializeReview();
  }

  void _updateProgress() {
    if (_dueCards.isEmpty) {
      _progressController.value = 1.0;
    } else {
      _progressController.value = _currentCardIndex / _dueCards.length;
    }
  }

  Future<void> _initializeReview() async {
    try {
      print('Initializing review...');
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      if (widget.deck.flashcards.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'No flashcards in this deck yet';
        });
        return;
      }

      // Get all cards for review
      _dueCards = List.from(widget.deck.flashcards);
      _dueCards.shuffle();
      print('Loaded ${_dueCards.length} cards for review');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentCardIndex = 0;
          _sessionComplete = false;
          _showAnswer = false;
          _updateProgress();
        });
      }
    } catch (e) {
      print('Error initializing review: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Failed to load review session';
        });
      }
    }
  }

  void _showNextCard() {
    if (_currentCardIndex < _dueCards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showAnswer = false;
        _updateProgress();
      });
    } else {
      setState(() {
        _sessionComplete = true;
      });
    }
  }

  void _toggleAnswer() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Review - ${widget.deck.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error loading review session',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeReview,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_sessionComplete) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Review Complete! 🎉',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'You reviewed ${_dueCards.length} cards',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Dashboard'),
            ),
          ],
        ),
      );
    }

    if (_dueCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Cards to Review',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add some flashcards to start reviewing',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Return to Dashboard'),
            ),
          ],
        ),
      );
    }

    // Show current flashcard
    final currentCard = _dueCards[_currentCardIndex];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Card ${_currentCardIndex + 1} of ${_dueCards.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GestureDetector(
              onTap: _toggleAnswer,
              child: Card(
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showAnswer ? 'Answer' : 'Question',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showAnswer ? currentCard.answer : currentCard.question,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (!_showAnswer) ...[
                        const SizedBox(height: 24),
                        const Text('Tap to show answer'),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_showAnswer) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _showNextCard,
                  child: const Text('Next Card'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
