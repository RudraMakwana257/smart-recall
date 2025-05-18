// lib/widgets/deck_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/deck_model.dart';
import '../utils/app_theme.dart';
import '../utils/responsive.dart';
import '../repositories/deck_repository.dart';
import 'dart:ui';
import 'dart:math' as math;

class DeckForm extends StatefulWidget {
  final Function(Deck) onSubmit;
  final VoidCallback onClose;
  final VoidCallback? onChanged;
  final Deck? initialDeck;
  final GlobalKey<FormState>? formKey;
  final bool showFormDirectly;

  const DeckForm({
    super.key,
    required this.onSubmit,
    required this.onClose,
    this.onChanged,
    this.initialDeck,
    this.formKey,
    this.showFormDirectly = false,
  });

  @override
  State<DeckForm> createState() => _DeckFormState();
}

class _DeckFormState extends State<DeckForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _tagController = TextEditingController();
  final _deckRepository = DeckRepository();
  List<String> _tags = [];
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _ellipseAnimation;
  final bool _isHovering = false;
  bool _hasFormChanges = false;
  final bool _isCreatingDeck = true;

  bool get _hasData {
    return _nameController.text.isNotEmpty ||
        _descController.text.isNotEmpty ||
        _tagController.text.isNotEmpty ||
        _tags.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialDeck != null) {
      _nameController.text = widget.initialDeck!.name;
      _descController.text = widget.initialDeck!.description;
      _tags = List.from(widget.initialDeck!.tags);
    }

    _nameController.addListener(_onFormChanged);
    _descController.addListener(_onFormChanged);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _ellipseAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // Start the entrance animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  void _onFormChanged() {
    widget.onChanged?.call();
    _hasFormChanges = true;
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormChanged);
    _descController.removeListener(_onFormChanged);
    _nameController.dispose();
    _descController.dispose();
    _tagController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitForm() async {
    final formKey = widget.formKey ?? _formKey;
    if (formKey.currentState!.validate()) {
      final deck = Deck(
        id: widget.initialDeck?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descController.text,
        tags: _tags,
        createdAt: widget.initialDeck?.createdAt ?? DateTime.now(),
        cardCount: widget.initialDeck?.cardCount ?? 0,
      );
      widget.onSubmit(deck);
    }
  }

  Future<bool> _confirmClose() async {
    if (!_hasFormChanges || !_hasData) {
      widget.onClose();
      return true;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.dashboard_rounded,
                    color: Colors.blue.shade400,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Leave Editor?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Do you want to go back to the dashboard\nor continue editing?',
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
                        onPressed: () => Navigator.pop(context, 'dashboard'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go to Dashboard',
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
                        onPressed: () => Navigator.pop(context, 'continue'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Continue Editing',
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
      ),
    );

    if (result == 'dashboard') {
      widget.onClose();
      return true;
    }
    return false;
  }

  void _handleClose() async {
    if (await _confirmClose()) {
      // Always navigate to dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color:
                  (isDarkMode ? Colors.black : Colors.black).withOpacity(0.2),
            ),
          ),
        ),

        // Animated background ellipse
        AnimatedBuilder(
          animation: _ellipseAnimation,
          builder: (context, child) {
            return Positioned(
              top: -screenSize.height * 0.3,
              right: -screenSize.width * 0.3,
              child: Transform.translate(
                offset: Offset(
                  100 * math.cos(_ellipseAnimation.value),
                  100 * math.sin(_ellipseAnimation.value),
                ),
                child: Transform.rotate(
                  angle: _ellipseAnimation.value,
                  child: Container(
                    width: screenSize.width * 1.2,
                    height: screenSize.height * 1.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                AppTheme.darkPrimaryPurple.withOpacity(0.4),
                                AppTheme.darkPrimaryBlue.withOpacity(0.4),
                              ]
                            : [
                                Colors.purple.shade300.withOpacity(0.4),
                                Colors.blue.shade300.withOpacity(0.4),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Second animated ellipse
        AnimatedBuilder(
          animation: _ellipseAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: -screenSize.height * 0.3,
              left: -screenSize.width * 0.3,
              child: Transform.translate(
                offset: Offset(
                  -100 * math.cos(_ellipseAnimation.value),
                  -100 * math.sin(_ellipseAnimation.value),
                ),
                child: Transform.rotate(
                  angle: -_ellipseAnimation.value,
                  child: Container(
                    width: screenSize.width * 1.2,
                    height: screenSize.height * 1.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                AppTheme.darkPrimaryBlue.withOpacity(0.15),
                                AppTheme.darkPrimaryPurple.withOpacity(0.15),
                              ]
                            : [
                                AppTheme.primaryBlue.withOpacity(0.15),
                                AppTheme.primaryPurple.withOpacity(0.15),
                              ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Main content
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDarkMode ? Colors.white : AppTheme.darkNavy,
                    ),
                    onPressed: _handleClose,
                    tooltip: 'Close',
                  ),
                  const SizedBox(width: 8),
                ],
                title: Text(
                  widget.initialDeck == null ? 'Create New Deck' : 'Edit Deck',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppTheme.darkNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                systemOverlayStyle: isDarkMode
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
              ),
            ),
          ),
          body: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              constraints: BoxConstraints(
                maxWidth: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width
                    : 500,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppTheme.darkCardBackground
                    : AppTheme.lightCardBackground,
                borderRadius:
                    BorderRadius.circular(AppTheme.borderRadiusMedium),
                boxShadow: isDarkMode
                    ? AppTheme.darkModeShadows
                    : AppTheme.lightModeShadows,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Form(
                  key: widget.formKey ?? _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Fill in the details below to create your flashcard deck',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Deck Name',
                          hintText: 'Example: "German Vocabulary"',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[50],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a deck name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                            TextFormField(
                              controller: _descController,
                              decoration: InputDecoration(
                                hintText: 'What is this deck about?',
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[500]
                                      : Colors.grey[400],
                                ),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: 'Tags',
                          hintText: 'Add tags and press Enter or click +',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.grey[50],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryBlue,
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: _addTag,
                            tooltip: 'Add Tag',
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        onFieldSubmitted: (_) => _addTag(),
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: _tags.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    'Added Tags',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _tags
                                        .map((tag) => Container(
                                              decoration: BoxDecoration(
                                                gradient:
                                                    AppTheme.primaryGradient,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Chip(
                                                label: Text(
                                                  tag,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                backgroundColor:
                                                    Colors.transparent,
                                                deleteIconColor: Colors.white,
                                                onDeleted: () =>
                                                    _removeTag(tag),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                widget.initialDeck == null
                                    ? 'Create Deck'
                                    : 'Update Deck',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
