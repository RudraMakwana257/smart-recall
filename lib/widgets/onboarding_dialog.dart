import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class OnboardingDialog extends StatefulWidget {
  const OnboardingDialog({super.key});

  @override
  State<OnboardingDialog> createState() => _OnboardingDialogState();
}

class _OnboardingDialogState extends State<OnboardingDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      icon: Icons.create_outlined,
      title: 'Create Flashcards',
      description:
          'Create digital flashcards for any subject you want to learn.',
    ),
    OnboardingStep(
      icon: Icons.psychology_outlined,
      title: 'Smart Review',
      description:
          'Our spaced repetition system helps you learn efficiently by showing cards at optimal intervals.',
    ),
    OnboardingStep(
      icon: Icons.trending_up_outlined,
      title: 'Track Progress',
      description:
          'Monitor your learning progress with detailed statistics and insights.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkBackground : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Welcome to Smart Recall',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s get you started with the basics',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDarkMode
                          ? AppTheme.darkTextSecondary
                          : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: isDarkMode
                                ? AppTheme.darkBlueGradient.scale(0.15)
                                : AppTheme.primaryGradient.scale(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.icon,
                            size: 48,
                            color: isDarkMode
                                ? AppTheme.darkPrimaryBlue
                                : AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          step.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          step.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDarkMode
                                ? AppTheme.darkTextSecondary
                                : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppTheme.darkTextSecondary
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (int i = 0; i < _steps.length; i++)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == _currentPage
                                ? (isDarkMode
                                    ? AppTheme.darkPrimaryBlue
                                    : AppTheme.primaryBlue)
                                : (isDarkMode
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey[300]),
                          ),
                        ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      if (_currentPage < _steps.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      _currentPage < _steps.length - 1 ? 'Next' : 'Get Started',
                      style: TextStyle(
                        color: isDarkMode
                            ? AppTheme.darkPrimaryBlue
                            : AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingStep {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
