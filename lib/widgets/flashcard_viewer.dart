import 'package:flutter/material.dart';
import 'dart:math' show pi;
import '../models/card_review_data.dart';
import '../services/srs_service.dart';
import '../utils/app_theme.dart';
import 'package:provider/provider.dart';

class FlashcardViewer extends StatefulWidget {
  final String cardId;
  final String question;
  final String answer;
  final VoidCallback? onNext;

  const FlashcardViewer({
    super.key,
    required this.cardId,
    required this.question,
    required this.answer,
    this.onNext,
  });

  @override
  State<FlashcardViewer> createState() => _FlashcardViewerState();
}

class _FlashcardViewerState extends State<FlashcardViewer>
    with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onNext != null) {
        widget.onNext!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!_isFlipped) {
      _controller.forward();
      setState(() {
        _isFlipped = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                side: BorderSide(
                  color: isDarkMode
                      ? AppTheme.darkPrimaryBlue.withOpacity(0.3)
                      : AppTheme.primaryBlue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Container(
                width: double.infinity,
                height: 400,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? AppTheme.darkBlueGradient.scale(0.2)
                      : AppTheme.primaryGradient.scale(0.1),
                  borderRadius:
                      BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_animation.value < pi / 2)
                      _buildFrontSide(theme)
                    else
                      Transform(
                        transform: Matrix4.identity()..rotateY(pi),
                        alignment: Alignment.center,
                        child: _buildBackSide(theme),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Question',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.question,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? AppTheme.darkPrimaryBlue.withOpacity(0.2)
                : AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.touch_app,
                size: 16,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 8),
              Text(
                'Tap to flip',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackSide(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Answer',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.answer,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Extension to scale gradients
extension GradientScale on Gradient {
  Gradient scale(double factor) {
    if (this is LinearGradient) {
      final LinearGradient gradient = this as LinearGradient;
      return LinearGradient(
        colors:
            gradient.colors.map((color) => color.withOpacity(factor)).toList(),
        begin: gradient.begin,
        end: gradient.end,
        stops: gradient.stops,
        transform: gradient.transform,
      );
    }
    return this;
  }
}
