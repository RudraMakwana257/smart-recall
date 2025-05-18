import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class Step {
  final String title;
  final String description;
  final IconData icon;
  final int number;

  Step(
      {required this.title,
      required this.description,
      required this.icon,
      required this.number});
}

class HowItWorksSection extends StatelessWidget {
  HowItWorksSection({super.key});

  final List<Step> steps = [
    Step(
      title: 'Create a deck with\nyour flashcards',
      description: 'Build custom flashcards for the topics you want to master',
      icon: Icons.create,
      number: 1,
    ),
    Step(
      title: 'Review flashcards\nas they become due',
      description:
          'Our algorithm will schedule the optimal time for each review',
      icon: Icons.access_time,
      number: 2,
    ),
    Step(
      title: 'Rate how well you\nremembered each card',
      description:
          'Your feedback helps the system optimize your learning schedule',
      icon: Icons.thumb_up,
      number: 3,
    ),
    Step(
      title: 'Watch your stats\nimprove over time!',
      description:
          'Track your progress and see your memory strengthen day by day',
      icon: Icons.trending_up,
      number: 4,
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
              'How It Works',
              style: TextStyle(
                fontFamily: 'Road Rage',
                fontSize: 64,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Simple steps to master any subject with our scientifically-proven approach',
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
              if (constraints.maxWidth >= 1024) {
                return _buildDesktopLayout();
              } else if (constraints.maxWidth >= 600) {
                return _buildTabletLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.map((step) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _StepCard(step: step),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _StepCard(step: steps[0])),
              const SizedBox(width: 24),
              Expanded(child: _StepCard(step: steps[1])),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _StepCard(step: steps[2])),
              const SizedBox(width: 24),
              Expanded(child: _StepCard(step: steps[3])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: steps.map((step) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _StepCard(step: step),
          );
        }).toList(),
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  final Step step;

  const _StepCard({required this.step});

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 0, end: _isHovered ? 1 : 0),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, -4 * value),
            child: Container(
              width: 280,
              height: 260,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color.lerp(
                    Colors.transparent,
                    Theme.of(context).primaryColor.withOpacity(0.3),
                    value,
                  )!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10 * value,
                    offset: Offset(0, 4 * value),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            widget.step.number.toString(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.step.title,
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
                        child: Text(
                          widget.step.description,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
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
                      ),
                    ],
                  ),
                  if (widget.step.number < 4)
                    Positioned(
                      right: -24,
                      top: 32,
                      child: CustomPaint(
                        size: const Size(48, 2),
                        painter: DashedLinePainter(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedLinePainter oldDelegate) => false;
}
