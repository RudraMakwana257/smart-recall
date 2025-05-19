import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/animated_gradient_button.dart';
import 'dashboard_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkBlueGradient.scale(0.15)
              : AppTheme.primaryGradient.scale(0.1),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo and Hero Section
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isDarkMode
                            ? AppTheme.darkBlueGradient
                            : AppTheme.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode
                                    ? AppTheme.darkPrimaryBlue
                                    : AppTheme.primaryBlue)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.psychology,
                        size: isTablet ? 96 : 72,
                        color: isDarkMode
                            ? AppTheme.darkTextPrimary
                            : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 48 : 32),

                  // Animated Content
                  FadeTransition(
                    opacity: _contentAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(_contentAnimation),
                      child: Column(
                        children: [
                          // Main Heading
                          Text(
                            'Boost Your Memory with\nSmart Recall',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 40 : 32,
                              height: 1.2,
                              color: isDarkMode
                                  ? AppTheme.darkTextPrimary
                                  : AppTheme.darkNavy,
                            ),
                          ),
                          SizedBox(height: isTablet ? 24 : 16),

                          // Subheading
                          Text(
                            'Create flashcards and review them using\nspaced repetition for long-term retention.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isDarkMode
                                  ? AppTheme.darkTextSecondary
                                  : Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: isTablet ? 64 : 48),

                          // CTA Buttons
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              AnimatedGradientButton(
                                onPressed: () =>
                                    context.pushReplacementWithTransition(
                                  const DashboardScreen(),
                                  fade: true,
                                  duration: const Duration(milliseconds: 500),
                                ),
                                label: 'Get Started',
                                icon: Icons.arrow_forward,
                                gradient: isDarkMode
                                    ? AppTheme.darkBlueGradient
                                    : AppTheme.primaryGradient,
                                isOutlined: false,
                              ),
                              AnimatedGradientButton(
                                onPressed: () => _showHowItWorks(context),
                                label: 'How It Works',
                                icon: Icons.help_outline,
                                gradient: isDarkMode
                                    ? AppTheme.darkBlueGradient
                                    : AppTheme.primaryGradient,
                                isOutlined: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHowItWorks(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkBackground : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'How Smart Recall Works',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildFeatureItem(
                    context,
                    icon: Icons.create,
                    title: 'Create Flashcards',
                    description:
                        'Create digital flashcards with questions and answers for any subject.',
                    color: Colors.blue,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.schedule,
                    title: 'Spaced Repetition',
                    description:
                        'Smart algorithm schedules reviews at optimal intervals for better retention.',
                    color: Colors.green,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.trending_up,
                    title: 'Track Progress',
                    description:
                        'Monitor your learning progress with detailed statistics and insights.',
                    color: Colors.orange,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.psychology,
                    title: 'Active Recall',
                    description:
                        'Test yourself actively to strengthen memory connections.',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardBackground : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode
                            ? AppTheme.darkTextSecondary
                            : Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
