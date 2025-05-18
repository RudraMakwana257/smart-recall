// lib/widgets/flashcard_view.dart
import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../utils/app_theme.dart';
import 'dart:math' show pi;

class FlashcardView extends StatefulWidget {
  final Flashcard card;
  final int cardNumber;
  final int totalCards;
  final bool showAnswer;
  final VoidCallback onShowAnswer;
  final Function(int) onRatingSelected;

  const FlashcardView({
    super.key,
    required this.card,
    required this.cardNumber,
    required this.totalCards,
    required this.showAnswer,
    required this.onShowAnswer,
    required this.onRatingSelected,
  });

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late Animation<double> _contentAnimation;
  bool _isFlipping = false;
  bool _showBackContent = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutQuad),
    );

    // Content fade animation that fades out in first half and fades in in second half
    _contentAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _flipController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _flipAnimation.addListener(() {
      if (_flipAnimation.value > pi / 2 && !_showBackContent) {
        setState(() => _showBackContent = true);
      }
    });

    _flipAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isFlipping = false);
      }
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.showAnswer && !_isFlipping) {
      setState(() => _isFlipping = true);
      widget.onShowAnswer();
      _flipController.forward();
    }
  }

  Widget _buildCardContent(BuildContext context, bool isDarkMode) {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        // Only show content when not in middle of flip
        if (_contentAnimation.value == 0) return const SizedBox.shrink();

        return Opacity(
          opacity: _contentAnimation.value,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showBackContent ? 'Answer' : 'Question',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _showBackContent
                        ? widget.card.answer
                        : widget.card.question,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final cardWidth = screenSize.width * 0.85;
    final cardHeight = screenSize.height * 0.5;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final isBack = _flipAnimation.value >= pi / 2;
                  final transformValue = isBack
                      ? (pi - _flipAnimation.value)
                      : _flipAnimation.value;

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(transformValue),
                    alignment: Alignment.center,
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [
                                  AppTheme.darkPrimaryBlue.withOpacity(0.15),
                                  AppTheme.darkPrimaryPurple.withOpacity(0.15),
                                ]
                              : [
                                  AppTheme.primaryBlue.withOpacity(0.1),
                                  AppTheme.primaryPurple.withOpacity(0.1),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMedium),
                        border: Border.all(
                          color: isDarkMode
                              ? AppTheme.darkPrimaryBlue.withOpacity(0.2)
                              : AppTheme.primaryBlue.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
      child: Padding(
                        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? AppTheme.darkPrimaryBlue
                                            .withOpacity(0.1)
                                        : AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${widget.cardNumber} of ${widget.totalCards}',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? AppTheme.darkPrimaryBlue
                                          : AppTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (widget.card.hint != null &&
                                    !_showBackContent)
                                  Tooltip(
                                    message: widget.card.hint!,
                                    child: Icon(
                                      Icons.lightbulb_outline,
                                      color: isDarkMode
                                          ? AppTheme.darkPrimaryPurple
                                          : AppTheme.primaryPurple,
                                    ),
                                  ),
                              ],
                            ),
            Expanded(
              child: Center(
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..rotateY(isBack ? pi : 0),
                                  alignment: Alignment.center,
                                  child: _buildCardContent(context, isDarkMode),
                                ),
                              ),
                            ),
                            if (!_showBackContent)
                              AnimatedBuilder(
                                animation: _contentAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _contentAnimation.value,
                child: Text(
                                      'Tap to reveal answer',
                  style: TextStyle(
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (_showBackContent)
          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
                children: [
                Text(
                    'How well did you remember?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                    _buildRatingButton(
                      'Again',
                      0,
                      Colors.red[400]!,
                      Icons.refresh,
                    ),
                    _buildRatingButton(
                      'Good',
                      1,
                      AppTheme.primaryBlue,
                      Icons.check,
                    ),
                    _buildRatingButton(
                      'Easy',
                      2,
                      Colors.green[400]!,
                      Icons.rocket_launch,
                  ),
                ],
              ),
          ],
        ),
      ),
      ],
    );
  }

  Widget _buildRatingButton(
      String label, int rating, Color color, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ElevatedButton(
      style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            elevation: 0,
            padding: const EdgeInsets.all(16),
            shape: const CircleBorder(),
          ),
          onPressed: () => widget.onRatingSelected(rating),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
