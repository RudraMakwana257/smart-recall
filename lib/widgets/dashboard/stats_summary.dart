import 'package:flutter/material.dart';
import '../../models/deck_model.dart';
import '../../utils/app_theme.dart';

class StatsSummary extends StatelessWidget {
  final List<Deck> decks;

  const StatsSummary({
    super.key,
    required this.decks,
  });

  // Memoized stats calculation
  Map<String, int> _calculateStats() {
    int totalCards = 0;
    int cardsReviewed = 0;
    int masteredCards = 0;

    for (final deck in decks) {
      totalCards += deck.flashcards.length;
      
      for (final card in deck.flashcards) {
        if (card.lastReviewed != null) {
          cardsReviewed++;
        }
        if (card.reviewLevel >= 3) {
          masteredCards++;
        }
      }
    }

    return {
      'totalCards': totalCards,
      'cardsReviewed': cardsReviewed,
      'masteredCards': masteredCards,
      'totalDecks': decks.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final isTablet = screenWidth > 600 && screenWidth <= 1024;

    final stats = _calculateStats();

    final statCards = [
      _StatCard(
        icon: Icons.library_books,
        label: 'Total Cards',
        value: stats['totalCards'].toString(),
        color: AppTheme.primaryBlue,
        isDarkMode: isDarkMode,
      ),
      _StatCard(
        icon: Icons.history,
        label: 'Cards Reviewed',
        value: stats['cardsReviewed'].toString(),
        color: AppTheme.primaryPurple,
        isDarkMode: isDarkMode,
      ),
      _StatCard(
        icon: Icons.star,
        label: 'Mastered',
        value: stats['masteredCards'].toString(),
        color: Colors.orange,
        isDarkMode: isDarkMode,
      ),
      _StatCard(
        icon: Icons.folder,
        label: 'Decks',
        value: stats['totalDecks'].toString(),
        color: Colors.green,
        isDarkMode: isDarkMode,
      ),
    ];

    if (isDesktop) {
      // Show all cards in a row with flexible width
      return Row(
        children: statCards
            .map((card) => Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: card,
                )))
            .toList(),
      );
    } else if (isTablet) {
      // Show cards in 2x2 grid
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: statCards,
      );
    } else {
      // Show cards in horizontal scrollable list for mobile
      return SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: statCards.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) => SizedBox(
            width: 120,
            child: statCards[index],
          ),
        ),
      );
    }
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDarkMode;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDarkMode,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? widget.color.withOpacity(0.15)
                : widget.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: widget.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      widget.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
