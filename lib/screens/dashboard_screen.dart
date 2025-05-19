import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../repositories/deck_repository.dart';
import '../utils/app_theme.dart';
import '../utils/toast_utils.dart';
import '../widgets/dashboard/welcome_header.dart';
import '../widgets/dashboard/stats_summary.dart';
import '../widgets/dashboard/deck_grid.dart';
import '../widgets/dashboard/action_buttons.dart';
import '../widgets/onboarding_dialog.dart';
import '../services/preferences_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DeckRepository _deckRepository = DeckRepository();
  final PreferencesService _preferencesService = PreferencesService();
  List<Deck> _decks = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadDecks();
    _deckRepository.addListener(_onDecksChanged);
    _checkFirstTimeUser();
  }

  @override
  void dispose() {
    _deckRepository.removeListener(_onDecksChanged);
    super.dispose();
  }

  void _onDecksChanged() {
    if (mounted) {
      _loadDecks();
    }
  }

  Future<void> _loadDecks() async {
    if (!_isRefreshing) {
      setState(() => _isLoading = true);
    }
    try {
      final decks = await _deckRepository.getAllDecks();
      if (mounted) {
        setState(() {
          _decks = decks;
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
        ToastUtils.showToast(
          context: context,
          message: 'Failed to load decks',
          isError: true,
        );
      }
    }
  }

  Future<void> _checkFirstTimeUser() async {
    final hasSeenOnboarding = await _preferencesService.hasSeenOnboarding;
    if (!hasSeenOnboarding && mounted) {
      // Show onboarding dialog after a short delay to allow the screen to build
      Future.delayed(const Duration(milliseconds: 500), () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const OnboardingDialog(),
        ).then((_) => _preferencesService.setHasSeenOnboarding(true));
      });
    }
  }

  void _navigateToCreateDeck() {
    Navigator.pushNamed(context, '/create-deck-form').then((_) => _loadDecks());
  }

  void _navigateToEditDeck(Deck deck) {
    Navigator.pushNamed(
      context,
      '/edit-deck',
      arguments: deck,
    ).then((_) => _loadDecks());
  }

  void _deleteDeck(Deck deck) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        backgroundColor:
            isDarkMode ? AppTheme.darkCardBackground : Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.delete_outline,
              color:
                  isDarkMode ? AppTheme.darkPrimaryBlue : AppTheme.primaryBlue,
            ),
            const SizedBox(width: 12),
            Text(
              'Delete Deck',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextPrimary
                    : theme.textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${deck.name}"?',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextSecondary
                    : theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDarkMode
                    ? AppTheme.darkTextSecondary.withOpacity(0.7)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDarkMode ? AppTheme.darkTextSecondary : Colors.grey[600],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _deckRepository.deleteDeck(deck.id);
                if (mounted) {
                  ToastUtils.showToast(
                    context: context,
                    message: 'Deck deleted successfully',
                    isError: false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ToastUtils.showToast(
                    context: context,
                    message: 'Failed to delete deck',
                    isError: true,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDarkMode ? AppTheme.darkPrimaryBlue : AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToReview(Deck deck) {
    Navigator.pushNamed(
      context,
      '/review',
      arguments: deck,
    ).then((_) => _loadDecks());
  }

  void _navigateToQuiz(Deck deck) {
    if (deck.flashcards.isEmpty) {
      ToastUtils.showToast(
        context: context,
        message: 'Add some cards to this deck first',
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/quiz',
      arguments: deck,
    ).then((_) => _loadDecks());
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToStats() {
    Navigator.pushNamed(context, '/stats');
  }

  void _startRandomQuiz() {
    if (_decks.isEmpty) {
      ToastUtils.showToast(
        context: context,
        message: 'Create some decks first to start a random quiz!',
      );
      return;
    }

    final random = DateTime.now().millisecondsSinceEpoch % _decks.length;
    _navigateToQuiz(_decks[random]);
  }

  Future<void> _refreshDashboard() async {
    setState(() => _isRefreshing = true);
    await _loadDecks();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: WelcomeHeader(
                    userName:
                        "User", // Replace with actual user name if available
                    onStatsPressed: _navigateToStats,
                    onSettingsPressed: _navigateToSettings,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pro Tip Section with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isDarkMode
                            ? AppTheme.darkBlueGradient.scale(0.15)
                            : AppTheme.primaryGradient.scale(0.1),
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.tips_and_updates,
                            color: isDarkMode
                                ? AppTheme.darkPrimaryBlue
                                : AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pro Tip: Regular review sessions help build long-term memory',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDarkMode
                                    ? AppTheme.darkTextSecondary
                                    : theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stats Summary
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      child: StatsSummary(decks: _decks),
                    ),
                    // Your Decks Section with animation
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _decks.isEmpty ? 0.7 : 1.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Decks',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _navigateToCreateDeck,
                            icon: const Icon(Icons.add),
                            label: const Text('New Deck'),
                            style: TextButton.styleFrom(
                              foregroundColor: isDarkMode
                                  ? AppTheme.darkPrimaryBlue
                                  : AppTheme.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.borderRadiusSmall,
                                ),
                                side: BorderSide(
                                  color: (isDarkMode
                                          ? AppTheme.darkPrimaryBlue
                                          : AppTheme.primaryBlue)
                                      .withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Deck Grid with animation
            DeckGrid(
              decks: _decks,
              onCreateDeck: _navigateToCreateDeck,
              onReview: _navigateToReview,
              onEdit: _navigateToEditDeck,
              onDelete: _deleteDeck,
            ),
          ],
        ),
      ),
    );
  }
}
