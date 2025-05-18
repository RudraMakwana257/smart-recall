import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onCreateDeck;
  final VoidCallback onRandomQuiz;

  const ActionButtons({
    super.key,
    required this.onCreateDeck,
    required this.onRandomQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppTheme.darkCardBackground
            : AppTheme.lightCardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.borderRadiusLarge),
          topRight: Radius.circular(AppTheme.borderRadiusLarge),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AnimatedButton(
              onPressed: onCreateDeck,
              icon: Icons.add,
              label: 'Create New Deck',
              gradient: AppTheme.primaryGradient,
              isDarkMode: isDarkMode,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _AnimatedButton(
              onPressed: onRandomQuiz,
              icon: Icons.shuffle,
              label: 'Random Quiz',
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.grey[800]!, Colors.grey[700]!]
                    : [Colors.grey[200]!, Colors.grey[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              isDarkMode: isDarkMode,
              textColor: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Gradient gradient;
  final bool isDarkMode;
  final Color? textColor;

  const _AnimatedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.gradient,
    required this.isDarkMode,
    this.textColor,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: widget.isDarkMode
                      ? Colors.black.withOpacity(_isHovered ? 0.3 : 0.2)
                      : Colors.black.withOpacity(_isHovered ? 0.2 : 0.1),
                  blurRadius: _isHovered ? 8 : 4,
                  offset: Offset(0, _isPressed ? 1 : (_isHovered ? 4 : 2)),
                ),
              ],
            ),
            transform: Matrix4.identity()
              ..translate(
                0.0,
                _isPressed ? 1.0 : (_isHovered ? -2.0 : 0.0),
              ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: widget.textColor ?? Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
