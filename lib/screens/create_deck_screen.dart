// lib/screens/create_deck_screen.dart
import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../repositories/deck_repository.dart';
import '../services/toast_service.dart';
import '../widgets/deck_form.dart';
import '../widgets/deck_card.dart';
import '../widgets/empty_deck_state.dart';
import 'package:provider/provider.dart';

class CreateDeckScreen extends StatefulWidget {
  final bool showFormDirectly;
  final Deck? initialDeck;

  const CreateDeckScreen({
    super.key,
    this.showFormDirectly = false,
    this.initialDeck,
  });

  @override
  State<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  final DeckRepository _deckRepository = DeckRepository();
  final ToastService _toastService = ToastService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Deck> _decks = [];
  bool _isLoading = true;
  bool _isCreatingDeck = false;
  bool _hasFormChanges = false;

  @override
  void initState() {
    super.initState();
    _loadDecks();
    if (widget.showFormDirectly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCreateDeckForm();
      });
    }
  }

  Future<void> _loadDecks() async {
    final decks = await _deckRepository.getAllDecks();
    setState(() {
      _decks = decks;
      _isLoading = false;
    });
  }

  Future<void> _createDeck(Deck deck) async {
    final newDeck = await _deckRepository.createDeck(
      name: deck.name,
      description: deck.description,
      tags: deck.tags,
    );

    if (context.mounted) {
      _toastService.showSuccessToast(
        context,
        'Deck "${deck.name}" created successfully!',
      );

      // Always navigate to dashboard after creating a deck
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (route) => false);
    }
  }

  Future<void> _updateDeck(Deck deck) async {
    await _deckRepository.updateDeck(deck);
    _toastService.showSuccessToast(
      context,
      'Deck "${deck.name}" updated successfully!',
    );
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> _deleteDeck(String deckId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.red.shade400,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Deck',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to delete this deck?\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete == true) {
      await _deckRepository.deleteDeck(deckId);
      _loadDecks();
      _toastService.showWarningToast(
        context,
        'Deck deleted',
      );
    }
  }

  void _showEditDialog(Deck deck) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.blue.shade400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Deck',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Make changes to "${deck.name}"',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),
                DeckForm(
                  initialDeck: deck,
                  onSubmit: (updatedDeck) {
                    _updateDeck(updatedDeck);
                    Navigator.pop(context);
                  },
                  onClose: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToAddCards(Deck deck) {
    Navigator.pushNamed(
      context,
      '/add-flashcard',
      arguments: deck,
    );
  }

  void _navigateToReview(Deck deck) {
    Navigator.pushNamed(
      context,
      '/review',
      arguments: deck,
    );
  }

  void _showCreateDeckForm() {
    setState(() => _isCreatingDeck = true);
  }

  void _handleBackNavigation() {
    final deckRepository = Provider.of<DeckRepository>(context, listen: false);
    deckRepository.getAllDecks().then((decks) {
      if (decks.isNotEmpty) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    });
  }

  void _handleClose() {
    final deckRepository = Provider.of<DeckRepository>(context, listen: false);
    deckRepository.getAllDecks().then((decks) {
      if (decks.isNotEmpty) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/dashboard', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    });
  }

  void _onFormChanged() {
    setState(() => _hasFormChanges = true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleClose();
        return false;
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Your Flashcard Decks'),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleBackNavigation,
              ),
              actions: [
                if (!_isCreatingDeck)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showCreateDeckForm,
                    tooltip: 'Create New Deck',
                  ),
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _decks.isEmpty
                    ? EmptyDeckState(onCreateDeck: _showCreateDeckForm)
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _decks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) => DeckCard(
                          deck: _decks[index],
                          onEdit: () => _showEditDialog(_decks[index]),
                          onDelete: () => _deleteDeck(_decks[index].id),
                          onAddCards: _navigateToAddCards,
                          onReview: _navigateToReview,
                        ),
                      ),
          ),
          if (_isCreatingDeck)
            DeckForm(
              formKey: _formKey,
              initialDeck: widget.initialDeck,
              onSubmit: _createDeck,
              onClose: _handleClose,
              onChanged: _onFormChanged,
            ),
        ],
      ),
    );
  }
}
