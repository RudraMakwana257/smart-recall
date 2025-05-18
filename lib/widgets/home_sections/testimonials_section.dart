import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class Testimonial {
  final String quote;
  final String name;
  final String role;
  final String? avatarUrl;

  Testimonial({
    required this.quote,
    required this.name,
    required this.role,
    this.avatarUrl,
  });
}

class TestimonialsSection extends StatelessWidget {
  TestimonialsSection({super.key});

  final List<Testimonial> testimonials = [
    Testimonial(
      quote:
          "Smart Recall changed how I study languages — I never forget vocabulary anymore!",
      name: "Anita",
      role: "Language Learner",
    ),
    Testimonial(
      quote:
          "The review stats keep me motivated daily. It's like having a personal tutor.",
      name: "Ravi",
      role: "Engineering Student",
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
              'What Our Users Say',
              style: TextStyle(
                fontFamily: 'Road Rage',
                fontSize: 64,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return _buildDesktopLayout();
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: testimonials.map((testimonial) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _TestimonialCard(testimonial: testimonial),
        );
      }).toList(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: testimonials.map((testimonial) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _TestimonialCard(testimonial: testimonial),
        );
      }).toList(),
    );
  }
}

class _TestimonialCard extends StatefulWidget {
  final Testimonial testimonial;

  const _TestimonialCard({required this.testimonial});

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0, end: _isHovered ? 1 : 0),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: 1 + (0.02 * value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: Border.all(
                  color: Color.lerp(
                    Colors.transparent,
                    Theme.of(context).primaryColor.withOpacity(0.3),
                    value,
                  )!,
                ),
                boxShadow: [
                  ...Theme.of(context).brightness == Brightness.light
                      ? AppTheme.lightModeShadows
                      : AppTheme.darkModeShadows,
                  if (_isHovered)
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          const Color(0xFF0062A3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds);
                    },
                    child: const Icon(
                      Icons.format_quote,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.testimonial.quote,
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      if (widget.testimonial.avatarUrl != null) ...[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                const Color(0xFF0062A3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              widget.testimonial.avatarUrl!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.testimonial.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2496B8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.testimonial.role,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
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
