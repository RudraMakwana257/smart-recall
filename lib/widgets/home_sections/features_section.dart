import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class Feature {
  final String title;
  final String description;
  final IconData icon;

  Feature({required this.title, required this.description, required this.icon});
}

class FeaturesSection extends StatelessWidget {
  FeaturesSection({super.key});

  final List<Feature> features = [
    Feature(
      title: '3D Flashcard\nViewer',
      description:
          'Beautiful 3D flip animations with intuitive grading buttons for spaced repetition review.',
      icon: Icons.flip_camera_android,
    ),
    Feature(
      title: 'Smart Spaced\nRepetition',
      description:
          'SmartRecall algorithm adapts to your performance, optimizing review intervals for maximum retention.',
      icon: Icons.psychology,
    ),
    Feature(
      title: 'Adaptive Quiz\nSystem',
      description:
          'Dynamic difficulty adjustment based on performance, with comprehensive progress tracking and statistics.',
      icon: Icons.quiz_outlined,
    ),
    Feature(
      title: 'Performance\nAnalytics',
      description:
          'Track memory strength, review history, and learning progress with detailed visual statistics.',
      icon: Icons.insights,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return AppTheme.primaryGradient.createShader(bounds);
            },
            child: const Text(
              'Powerful Features',
              style: TextStyle(
                fontFamily: 'Road Rage',
                fontSize: 64,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Advanced learning tools powered by spaced repetition and adaptive algorithms',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              // Desktop view (≥ 1024px)
              if (constraints.maxWidth >= 1024) {
                return _buildDesktopLayout();
              }
              // Tablet view (600px - 1023px)
              else if (constraints.maxWidth >= 600) {
                return _buildTabletLayout();
              }
              // Mobile view (< 600px)
              else {
                return _buildMobileLayout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      alignment: WrapAlignment.center,
      children: features
          .map((feature) => SizedBox(
                width: 280,
                height: 280,
                child: FeatureCard(feature: feature),
              ))
          .toList(),
    );
  }

  Widget _buildTabletLayout() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: features
          .map((feature) => SizedBox(
                width: 260,
                height: 260,
                child: FeatureCard(feature: feature),
              ))
          .toList(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: FeatureCard(feature: feature),
                ),
              ))
          .toList(),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final Feature feature;

  const FeatureCard({
    super.key,
    required this.feature,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _isHovered = false;
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        if (!_isExpanded) {
          _isExpanded = false;
        }
      }),
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: _isHovered
              ? (Matrix4.identity()..translate(0, -5))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 10 : 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    widget.feature.icon,
                    size: 32,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.feature.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Color(0xFF2496B8),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Stack(
                  children: [
                    AnimatedCrossFade(
                      firstChild: Text(
                        widget.feature.description,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                      secondChild: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              widget.feature.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isExpanded) _buildExpandedContent(context),
                          ],
                        ),
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    if (_isHovered && !_isExpanded)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).cardColor.withOpacity(0),
                                Theme.of(context).cardColor,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.only(top: 20, bottom: 8),
                          child: Center(
                            child: Text(
                              'Learn More',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(BuildContext context) {
    Map<String, String> additionalInfo = _getAdditionalInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: additionalInfo.entries
          .map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF2496B8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Map<String, String> _getAdditionalInfo() {
    switch (widget.feature.title) {
      case '3D Flashcard\nViewer':
        return {
          'Animations':
              'Smooth 3D flip transitions with realistic physics and shadows',
          'Grading Options':
              'Again, Hard, Good, and Easy buttons for precise feedback',
          'Dark Mode':
              'Beautiful gradient styling that adapts to light and dark themes',
          'Interaction':
              'Intuitive touch and click controls for card manipulation'
        };
      case 'Smart Spaced\nRepetition':
        return {
          'Algorithm':
              'Advanced SmartRecall system based on proven memory research',
          'Adaptivity':
              'Review intervals automatically adjust to your learning pace',
          'Memory Strength':
              'Sophisticated tracking of individual card retention rates',
          'Optimization':
              'Continuous refinement of review scheduling for best results'
        };
      case 'Adaptive Quiz\nSystem':
        return {
          'Difficulty Levels':
              'Dynamic adjustment based on performance patterns',
          'Progress Tracking':
              'Detailed metrics for quiz performance and improvement',
          'Feedback System':
              'Immediate response with visual success indicators',
          'Session Stats': 'Comprehensive end-of-quiz performance analysis'
        };
      case 'Performance\nAnalytics':
        return {
          'Memory Metrics':
              'Detailed tracking of retention rates and learning curves',
          'Review History':
              'Complete log of all study sessions and performance',
          'Visual Stats':
              'Interactive charts and graphs for progress visualization',
          'Learning Insights':
              'Actionable recommendations based on your study patterns'
        };
      default:
        return {};
    }
  }
}
