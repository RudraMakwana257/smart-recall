// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/learning_progress_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_stats_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
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
    final progressService = Provider.of<LearningProgressService>(context);
    final quizPerformance = progressService.getQuizPerformance();
    final masteryDistribution = progressService.getMasteryDistribution();

    // Check if there's any data to show
    final hasData = quizPerformance['totalQuizzes'] > 0 ||
        masteryDistribution.values.any((value) => value > 0);

    if (!hasData) {
      return const Scaffold(
        body: EmptyStatsState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quiz Performance',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAnimatedStatItem(
                              'Total Quizzes',
                              quizPerformance['totalQuizzes'].toString(),
                            ),
                            _buildAnimatedStatItem(
                              'Avg. Score',
                              '${(quizPerformance['averageScore'] * _chartAnimation.value).toStringAsFixed(1)}%',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAnimatedStatItem(
                              'Correct Answers',
                              '${(quizPerformance['correctAnswers'] * _chartAnimation.value).toInt()}/${quizPerformance['totalQuestions']}',
                            ),
                            _buildAnimatedStatItem(
                              'Avg. Duration',
                              _formatDuration(
                                  quizPerformance['averageDuration']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Mastery Distribution',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return Container(
                    height: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: masteryDistribution['Mastered']! *
                                _chartAnimation.value,
                            title:
                                '${(masteryDistribution['Mastered']! * _chartAnimation.value).toStringAsFixed(1)}%\nMastered',
                            color: AppTheme.primaryBlue,
                            radius: 100 * _chartAnimation.value,
                          ),
                          PieChartSectionData(
                            value: masteryDistribution['Learning']! *
                                _chartAnimation.value,
                            title:
                                '${(masteryDistribution['Learning']! * _chartAnimation.value).toStringAsFixed(1)}%\nLearning',
                            color: AppTheme.primaryPurple,
                            radius: 100 * _chartAnimation.value,
                          ),
                          PieChartSectionData(
                            value: masteryDistribution['New']! *
                                _chartAnimation.value,
                            title:
                                '${(masteryDistribution['New']! * _chartAnimation.value).toStringAsFixed(1)}%\nNew',
                            color: Colors.grey,
                            radius: 100 * _chartAnimation.value,
                          ),
                        ],
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
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
  }

  Widget _buildAnimatedStatItem(String label, String value) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, animationValue, child) {
        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animationValue)),
            child: Column(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
