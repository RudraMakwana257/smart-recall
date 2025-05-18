import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_service.dart';
import '../models/quiz_data.dart';
import '../utils/app_theme.dart';
import '../widgets/flashcard_viewer.dart';

class QuizView extends StatefulWidget {
  final String deckId;
  final List<String> cardIds;

  const QuizView({
    super.key,
    required this.deckId,
    required this.cardIds,
  });

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  bool _showAnswer = false;
  bool _showFeedback = false;
  bool? _lastAnswer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQuiz();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    final quizService = Provider.of<QuizService>(context, listen: false);
    await quizService.startQuiz(widget.deckId, widget.cardIds);
    _updateProgress();
  }

  void _updateProgress() {
    final session =
        Provider.of<QuizService>(context, listen: false).activeSession;
    if (session != null) {
      final progress = session.currentIndex / session.cardIds.length;
      _progressController.animateTo(progress);
    }
  }

  void _handleAnswer(bool isCorrect) {
    setState(() {
      _lastAnswer = isCorrect;
      _showFeedback = true;
    });

    final quizService = Provider.of<QuizService>(context, listen: false);
    final session = quizService.activeSession;
    if (session != null) {
      final currentCardId = session.cardIds[session.currentIndex];
      quizService.recordAnswer(currentCardId, isCorrect);
      _updateProgress();

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _showAnswer = false;
            _showFeedback = false;
            _lastAnswer = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizService>(
      builder: (context, quizService, child) {
        final session = quizService.activeSession;
        if (session == null || session.isComplete) {
          return _buildCompletionScreen(quizService.stats);
        }

        final currentCardId = session.cardIds[session.currentIndex];

        return Scaffold(
          appBar: AppBar(
            title:
                Text('Quiz - ${session.currentDifficulty.name.toUpperCase()}'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${session.currentIndex + 1}/${session.cardIds.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Score: ${session.score.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FlashcardViewer(
                          cardId: currentCardId,
                          question:
                              'Sample Question', // Replace with actual data
                          answer: 'Sample Answer', // Replace with actual data
                        ),
                      ),
                      if (_showFeedback)
                        AnimatedOpacity(
                          opacity: _showFeedback ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            color: (_lastAnswer ?? false)
                                ? Colors.green.withOpacity(0.3)
                                : Colors.red.withOpacity(0.3),
                            child: Center(
                              child: Icon(
                                (_lastAnswer ?? false)
                                    ? Icons.check_circle_outline
                                    : Icons.cancel_outlined,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!_showFeedback)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAnswerButton(
                          'Incorrect',
                          Colors.red,
                          () => _handleAnswer(false),
                        ),
                        _buildAnswerButton(
                          'Correct',
                          Colors.green,
                          () => _handleAnswer(true),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCompletionScreen(QuizStats stats) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isDarkMode
                    ? AppTheme.darkModeGradient
                    : AppTheme.primaryGradient,
              ),
              child: const Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Complete!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Average Score: ${stats.averageScore.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Return to Deck',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
