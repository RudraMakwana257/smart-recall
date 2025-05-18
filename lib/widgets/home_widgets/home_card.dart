import 'dart:async';
import 'package:flutter/material.dart';

class FlashCardHome extends StatefulWidget {
  const FlashCardHome({super.key});

  @override
  State<FlashCardHome> createState() => _FlashCardHomeState();
}

class _FlashCardHomeState extends State<FlashCardHome> {
  final List<Map<String, Offset>> framePositions = [
    {'A': const Offset(0, 154), 'B': const Offset(129, 77), 'C': const Offset(260, 0)},
    {'A': const Offset(0, -4), 'B': const Offset(129, 77), 'C': const Offset(274, 0)},
    {'A': const Offset(260, 154), 'B': const Offset(129, 77), 'C': const Offset(0, -4)},
    {'A': const Offset(0, -4), 'B': const Offset(257, 77), 'C': const Offset(130, 154)},
    {'A': const Offset(130, 154), 'B': const Offset(257, 77), 'C': const Offset(0, -4)},
  ];

  final List<Map<String, String>> cardData = [
    {
      "title": "Spaced Repetition",
      "description":
          "Efficiently review flashcards at optimal intervals for long-term memory retention.",
    },
    {
      "title": "Progress Tracking",
      "description":
          "Monitor your learning stats, mastered cards, and daily review history.",
    },
    {
      "title": "Smart Scheduling",
      "description":
          "Our engine adapts to your memory strength and schedules reviews intelligently.",
    },
  ];

  int currentFrame = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      setState(() {
        currentFrame = (currentFrame + 1) % framePositions.length;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 600 ? 0.7 : 1.0;
    final frame = framePositions[currentFrame];

    return SizedBox(
      width: 496 * scaleFactor,
      height: 485 * scaleFactor,
      child: Stack(
        children: [
          _buildAnimatedCard(
            key: const ValueKey('cardA'),
            offset: frame['A']! * scaleFactor,
            cardIndex: 0,
            scaleFactor: scaleFactor,
          ),
          _buildAnimatedCard(
            key: const ValueKey('cardB'),
            offset: frame['B']! * scaleFactor,
            cardIndex: 1,
            scaleFactor: scaleFactor,
          ),
          _buildAnimatedCard(
            key: const ValueKey('cardC'),
            offset: frame['C']! * scaleFactor,
            cardIndex: 2,
            scaleFactor: scaleFactor,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({
    required Offset offset,
    required int cardIndex,
    required Key key,
    required double scaleFactor,
  }) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      left: offset.dx,
      top: offset.dy,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: 1.0,
        child: Transform.scale(
          scale: scaleFactor,
          child: FlashCard(
            key: key,
            title: cardData[cardIndex]['title']!,
            description: cardData[cardIndex]['description']!,
          ),
        ),
      ),
    );
  }
}

class FlashCard extends StatelessWidget {
  final String title;
  final String description;

  const FlashCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      height: 326,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
