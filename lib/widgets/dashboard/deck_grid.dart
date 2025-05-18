import 'package:flutter/material.dart';
import '../../models/deck_model.dart';
import '../../utils/app_theme.dart';
import '../../repositories/deck_repository.dart';

class DeckGrid extends StatelessWidget {
  final List<Deck> decks;
  final Function(Deck) onReview;
  final Function(Deck) onEdit;
  final Function(Deck)? onDelete;

  const DeckGrid({
    super.key,
    required this.decks,
    required this.onReview,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (decks.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.darkBlueGradient.scale(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.library_books_outlined,
                  size: 48,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.darkTextPrimary
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No decks yet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first deck to start learning',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.darkTextSecondary
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 180, // Slightly increased to accommodate the button
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _DeckCard(
            deck: decks[index],
            onReview: onReview,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          childCount: decks.length,
        ),
      ),
    );
  }
}

class _DeckCard extends StatefulWidget {
  final Deck deck;
  final Function(Deck) onReview;
  final Function(Deck) onEdit;
  final Function(Deck)? onDelete;

  const _DeckCard({
    required this.deck,
    required this.onReview,
    required this.onEdit,
    this.onDelete,
  });

  @override
  State<_DeckCard> createState() => _DeckCardState();
}

class _DeckCardState extends State<_DeckCard> {
  bool _isHovered = false;
  bool _isDeleting = false;

  void _handleEdit() {
    try {
      widget.onEdit(widget.deck);
    } catch (e) {
      _showErrorDialog('Failed to edit deck');
    }
  }

  void _handleDelete() async {
    if (_isDeleting) return;

    setState(() => _isDeleting = true);
    try {
      await widget.onDelete?.call(widget.deck);
    } catch (e) {
      _showErrorDialog('Failed to delete deck');
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkBlueGradient.scale(0.1)
              : AppTheme.primaryGradient.scale(0.05),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.1 : 0.05),
              blurRadius: _isHovered ? 12 : 8,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.deck.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? AppTheme.darkTextPrimary
                                  : theme.textTheme.titleLarge?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: isDarkMode
                                ? AppTheme.darkTextSecondary
                                : theme.textTheme.bodyMedium?.color,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusMedium),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: isDarkMode
                                        ? AppTheme.darkPrimaryBlue
                                        : AppTheme.primaryBlue,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Edit'),
                                ],
                              ),
                            ),
                            if (widget.onDelete != null)
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('Delete'),
                                  ],
                                ),
                              ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                _handleEdit();
                                break;
                              case 'delete':
                                _handleDelete();
                                break;
                            }
                          },
                        ),
                      ],
                    ),
                    if (widget.deck.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.deck.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? AppTheme.darkTextSecondary
                              : theme.textTheme.bodyMedium?.color,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 16,
                          color: isDarkMode
                              ? AppTheme.darkTextSecondary
                              : theme.textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.deck.flashcards.length} cards',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDarkMode
                                ? AppTheme.darkTextSecondary
                                : theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: (isDarkMode
                            ? AppTheme.darkPrimaryBlue
                            : AppTheme.primaryBlue)
                        .withOpacity(0.1),
                  ),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    print(
                        'Navigating to review with deck: ${widget.deck.name}');
                    print('Deck ID: ${widget.deck.id}');
                    print('Flashcards count: ${widget.deck.flashcards.length}');
                    if (widget.deck.flashcards.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Add some flashcards to this deck before reviewing',
                          ),
                          action: SnackBarAction(
                            label: 'Add Cards',
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/add-flashcard',
                                arguments: widget.deck,
                              );
                            },
                          ),
                        ),
                      );
                      return;
                    }
                    Navigator.pushNamed(
                      context,
                      '/review',
                      arguments: widget.deck,
                    );
                  },
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppTheme.borderRadiusLarge),
                    bottomRight: Radius.circular(AppTheme.borderRadiusLarge),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book,
                          size: 20,
                          color: isDarkMode
                              ? AppTheme.darkPrimaryBlue
                              : AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Review Flashcards',
                          style: TextStyle(
                            color: isDarkMode
                                ? AppTheme.darkPrimaryBlue
                                : AppTheme.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
