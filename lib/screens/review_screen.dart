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
import '../utils/page_transitions.dart';
import 'dashboard_screen.dart';

class ReviewScreen extends StatefulWidget {
  final Deck deck;

  const ReviewScreen({super.key, required this.deck});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with TickerProviderStateMixin {
  final DeckRepository _deckRepository = DeckRepository();
  final ReviewService _reviewService = ReviewService();
  List<Flashcard> _dueCards = [];
  int _currentCardIndex = 0;
  bool _showAnswer = false;
  bool _sessionComplete = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _streak = 0;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

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

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));

    _initializeReview();
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
          _hasError = false;
          _dueCards = [];
        });
        return;
      }

      // Get due cards using the review service
      _dueCards = ReviewService.getDueFlashcards(widget.deck);
      print('Loaded ${_dueCards.length} due cards for review');

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

  void _handleReviewResponse(int quality) async {
    final currentCard = _dueCards[_currentCardIndex];
    final updatedCard =
        ReviewService.processReviewResponse(currentCard, quality);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Update streak
    if (quality >= 3) {
      setState(() {
        _streak++;
      });
    } else {
      setState(() {
        _streak = 0;
      });
    }

    try {
      // Update the flashcard in the deck
      final deckIndex = widget.deck.flashcards
          .indexWhere((card) => card.id == currentCard.id);
      if (deckIndex != -1) {
        widget.deck.flashcards[deckIndex] = updatedCard;
        await _deckRepository.updateDeck(widget.deck);
      }

      // Show next review time with animation
      if (mounted) {
        final nextReview = ReviewService.getNextReviewTime(updatedCard);
        final hours = nextReview.difference(DateTime.now()).inHours;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Next review scheduled in ${hours > 24 ? '${(hours / 24).floor()} days' : '$hours hours'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (_streak > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '$_streak',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            backgroundColor:
                isDarkMode ? AppTheme.darkPrimaryBlue : AppTheme.primaryBlue,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100,
              left: 20,
              right: 20,
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      _showNextCard();
    } catch (e) {
      print('Error updating flashcard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to save review progress'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      _showNextCard();
    }
  }

  void _showNextCard() {
    if (_currentCardIndex < _dueCards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showAnswer = false;
        _updateProgress();
      });
      _cardController.forward(from: 0.0);
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
    _cardController.forward(from: 0.0);
  }

  void _updateProgress() {
    if (_dueCards.isEmpty) {
      _progressController.value = 1.0;
    } else {
      _progressController.value = _currentCardIndex / _dueCards.length;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review Flashcards',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : theme.textTheme.titleLarge?.color,
              ),
            ),
            Text(
              widget.deck.name,
              style: theme.textTheme.titleSmall?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : theme.textTheme.titleSmall?.color,
              ),
            ),
            if (_streak > 0)
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '$_streak day streak',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: _progressAnimation.value,
            backgroundColor: isDarkMode
                ? AppTheme.darkSecondaryBackground
                : Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? AppTheme.darkPrimaryBlue : AppTheme.primaryBlue,
            ),
          ),
        ),
        actions: [
          if (!_sessionComplete && !_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor:
                            isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode
                              ? AppTheme.darkPrimaryBlue
                              : AppTheme.primaryBlue,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(isDarkMode, theme),
    );
  }

  Widget _buildBody(bool isDarkMode, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isLandscape = screenWidth > screenHeight;
        final isTablet = screenWidth > 600;
        final isMobile = screenWidth <= 600;

        // Calculate responsive dimensions
        final cardWidth =
            isTablet ? constraints.maxWidth * 0.7 : constraints.maxWidth * 0.92;
        final cardHeight = isLandscape
            ? constraints.maxHeight * 0.6
            : constraints.maxHeight * 0.45;
        final cardPadding = isTablet ? 32.0 : 20.0;
        final buttonSpacing = isTablet ? 24.0 : 16.0;
        final fontSize = isTablet
            ? theme.textTheme.headlineLarge?.fontSize
            : theme.textTheme.headlineMedium?.fontSize;

        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_hasError) {
          return _buildErrorState(isDarkMode, theme, cardWidth, cardPadding);
        }

        if (widget.deck.flashcards.isEmpty || _dueCards.isEmpty) {
          return _buildEmptyState(isDarkMode, theme, cardWidth, cardPadding);
        }

        if (_sessionComplete) {
          return _buildCompleteState(isDarkMode, theme, cardWidth, cardPadding);
        }

        // Show current flashcard with responsive layout
        final currentCard = _dueCards[_currentCardIndex];
        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 24.0,
                vertical: isMobile ? 16.0 : 24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (isMobile ? 32.0 : 48.0),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Review Progress Header
                      Container(
                        width: cardWidth,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 16.0 : 20.0,
                          horizontal: isMobile ? 20.0 : 24.0,
                        ),
                        decoration: BoxDecoration(
                          gradient: isDarkMode
                              ? AppTheme.darkBlueGradient.scale(0.15)
                              : AppTheme.primaryGradient.scale(0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.borderRadiusLarge),
                          boxShadow: isDarkMode
                              ? AppTheme.darkModeShadows
                              : AppTheme.lightModeShadows,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Due Today: ${_dueCards.length} Cards',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: isDarkMode
                                        ? AppTheme.darkTextPrimary
                                        : theme.textTheme.titleLarge?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Tooltip(
                                  message:
                                      'Spaced repetition is a learning technique that helps you remember information for longer by reviewing it at increasing intervals. The more confident you are with a card, the longer until its next review.',
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.help_outline,
                                      color: isDarkMode
                                          ? AppTheme.darkTextSecondary
                                          : Colors.grey[600],
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Card ${_currentCardIndex + 1} of ${_dueCards.length}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: isDarkMode
                                    ? AppTheme.darkTextSecondary
                                    : theme.textTheme.titleMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: buttonSpacing * 1.5),

                      // Flashcard
                      GestureDetector(
                        onTap: _toggleAnswer,
                        child: Container(
                          width: cardWidth,
                          height: cardHeight,
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? AppTheme.darkBlueGradient.scale(0.15)
                                : AppTheme.primaryGradient.scale(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusLarge),
                            border: Border.all(
                              color: isDarkMode
                                  ? AppTheme.darkPrimaryBlue.withOpacity(0.2)
                                  : AppTheme.primaryBlue.withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: isDarkMode
                                ? AppTheme.darkModeShadows
                                : AppTheme.lightModeShadows,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.all(cardPadding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _showAnswer ? 'Answer' : 'Question',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: isDarkMode
                                        ? AppTheme.darkTextSecondary
                                        : theme.textTheme.titleMedium?.color,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: buttonSpacing),
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: cardPadding,
                                          vertical: buttonSpacing,
                                        ),
                                        child: Text(
                                          _showAnswer
                                              ? currentCard.answer
                                              : currentCard.question,
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? AppTheme.darkTextPrimary
                                                : theme.textTheme.headlineMedium
                                                    ?.color,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (!_showAnswer) ...[
                                  SizedBox(height: buttonSpacing),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        size: 20,
                                        color: isDarkMode
                                            ? AppTheme.darkTextSecondary
                                            : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tap to show answer',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: isDarkMode
                                              ? AppTheme.darkTextSecondary
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Review Buttons
                      if (_showAnswer) ...[
                        SizedBox(height: buttonSpacing * 1.5),
                        Container(
                          width: cardWidth,
                          padding: EdgeInsets.all(cardPadding),
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? AppTheme.darkBlueGradient.scale(0.15)
                                : AppTheme.primaryGradient.scale(0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusLarge),
                            boxShadow: isDarkMode
                                ? AppTheme.darkModeShadows
                                : AppTheme.lightModeShadows,
                          ),
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: buttonSpacing,
                              runSpacing: buttonSpacing,
                              children: [
                                _buildReviewButton(
                                  isDarkMode,
                                  'Again',
                                  Icons.refresh,
                                  Colors.red[400]!,
                                  () => _handleReviewResponse(0),
                                  theme,
                                ),
                                _buildReviewButton(
                                  isDarkMode,
                                  'Good',
                                  Icons.thumb_up,
                                  Colors.green[400]!,
                                  () => _handleReviewResponse(1),
                                  theme,
                                ),
                                _buildReviewButton(
                                  isDarkMode,
                                  'Easy',
                                  Icons.rocket_launch,
                                  AppTheme.primaryBlue,
                                  () => _handleReviewResponse(2),
                                  theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewButton(
    bool isDarkMode,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDarkMode,
    ThemeData theme,
    double width,
    double padding,
  ) {
    return Center(
      child: Container(
        width: width,
        margin: EdgeInsets.all(padding),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkBlueGradient.scale(0.15)
              : AppTheme.primaryGradient.scale(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow:
              isDarkMode ? AppTheme.darkModeShadows : AppTheme.lightModeShadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? AppTheme.darkBlueGradient
                    : AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: 48,
                color: isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.deck.flashcards.isEmpty
                  ? 'This deck is empty. Add flashcards to begin reviewing.'
                  : 'All Caught Up! 🎉',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.deck.flashcards.isEmpty
                  ? 'Create your first flashcard to start learning!'
                  : 'Come back tomorrow for more practice.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.deck.flashcards.isEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/add-flashcard',
                        arguments: widget.deck,
                      ).then((_) => _initializeReview());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Flashcards'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      backgroundColor: isDarkMode
                          ? AppTheme.darkPrimaryBlue
                          : AppTheme.primaryBlue,
                    ),
                  ),
                if (widget.deck.flashcards.isEmpty) const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => context.pushReplacementWithTransition(
                    const DashboardScreen(),
                    direction: SlideDirection.left,
                  ),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Return to Dashboard'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    side: BorderSide(
                      color: isDarkMode
                          ? AppTheme.darkPrimaryBlue
                          : AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteState(
    bool isDarkMode,
    ThemeData theme,
    double width,
    double padding,
  ) {
    return Center(
      child: Container(
        width: width,
        margin: EdgeInsets.all(padding),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkBlueGradient.scale(0.15)
              : AppTheme.primaryGradient.scale(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow:
              isDarkMode ? AppTheme.darkModeShadows : AppTheme.lightModeShadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDarkMode
                    ? AppTheme.darkBlueGradient
                    : AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                size: 48,
                color: isDarkMode ? AppTheme.darkTextPrimary : Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Review Complete! 🎉',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You reviewed ${_dueCards.length} cards',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.pushReplacementWithTransition(
                const DashboardScreen(),
                direction: SlideDirection.left,
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Return to Dashboard'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                backgroundColor: isDarkMode
                    ? AppTheme.darkPrimaryBlue
                    : AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    bool isDarkMode,
    ThemeData theme,
    double width,
    double padding,
  ) {
    return Center(
      child: Container(
        width: width,
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error loading review session',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : theme.textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeReview,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
