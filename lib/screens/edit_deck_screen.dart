import 'package:flutter/material.dart';
import '../models/deck_model.dart';
import '../repositories/deck_repository.dart';
import '../utils/app_theme.dart';
import '../utils/toast_utils.dart';

class EditDeckScreen extends StatefulWidget {
  final Deck deck;

  const EditDeckScreen({super.key, required this.deck});

  @override
  State<EditDeckScreen> createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends State<EditDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deckRepository = DeckRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.deck.name;
    _descriptionController.text = widget.deck.description;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveDeck() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedDeck = Deck(
        id: widget.deck.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        tags: widget.deck.tags,
        flashcards: widget.deck.flashcards,
        createdAt: widget.deck.createdAt,
      );

      await _deckRepository.updateDeck(updatedDeck);
      if (mounted) {
        ToastUtils.showToast(
          context: context,
          message: 'Deck updated successfully',
          isError: false,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showToast(
          context: context,
          message: 'Failed to update deck',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Deck'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? AppTheme.darkBlueGradient.scale(0.15)
              : AppTheme.primaryGradient.scale(0.1),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? AppTheme.darkBlueGradient.scale(0.15)
                          : AppTheme.primaryGradient.scale(0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      boxShadow: isDarkMode
                          ? AppTheme.darkModeShadows
                          : AppTheme.lightModeShadows,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note,
                              color: isDarkMode
                                  ? AppTheme.darkPrimaryBlue
                                  : AppTheme.primaryBlue,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Edit Deck Details',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: isDarkMode
                                    ? AppTheme.darkTextPrimary
                                    : theme.textTheme.titleLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Update your deck information below',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDarkMode
                                ? AppTheme.darkTextSecondary
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Deck Name Field
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.darkCardBackground
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      boxShadow: isDarkMode
                          ? AppTheme.darkModeShadows
                          : AppTheme.lightModeShadows,
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Deck Name',
                        hintText: 'Enter a name for your deck',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium),
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? AppTheme.darkSecondaryBackground
                            : Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a deck name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Field
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.darkCardBackground
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      boxShadow: isDarkMode
                          ? AppTheme.darkModeShadows
                          : AppTheme.lightModeShadows,
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter a description for your deck',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium),
                        ),
                        filled: true,
                        fillColor: isDarkMode
                            ? AppTheme.darkSecondaryBackground
                            : Colors.grey[50],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      boxShadow: isDarkMode
                          ? AppTheme.darkModeShadows
                          : AppTheme.lightModeShadows,
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveDeck,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isDarkMode
                            ? AppTheme.darkPrimaryBlue
                            : AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusMedium),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Deck Statistics
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? AppTheme.darkBlueGradient.scale(0.15)
                          : AppTheme.primaryGradient.scale(0.1),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusLarge),
                      boxShadow: isDarkMode
                          ? AppTheme.darkModeShadows
                          : AppTheme.lightModeShadows,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: isDarkMode
                                  ? AppTheme.darkPrimaryBlue
                                  : AppTheme.primaryBlue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Deck Statistics',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: isDarkMode
                                    ? AppTheme.darkTextPrimary
                                    : theme.textTheme.titleLarge?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatItem(
                              context,
                              Icons.style,
                              'Total Cards',
                              widget.deck.cardCount.toString(),
                              isDarkMode,
                            ),
                            const SizedBox(width: 24),
                            _buildStatItem(
                              context,
                              Icons.calendar_today,
                              'Created',
                              _formatDate(widget.deck.createdAt),
                              isDarkMode,
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkSecondaryBackground : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          boxShadow:
              isDarkMode ? AppTheme.darkModeShadows : AppTheme.lightModeShadows,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color:
                  isDarkMode ? AppTheme.darkPrimaryBlue : AppTheme.primaryBlue,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode
                        ? AppTheme.darkTextSecondary
                        : Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isDarkMode
                        ? AppTheme.darkTextPrimary
                        : Theme.of(context).textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
