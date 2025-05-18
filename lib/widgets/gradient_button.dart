import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../utils/app_theme.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeService>(context).darkMode;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? AppTheme.darkModeGradient
                : AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode
                        ? AppTheme.darkPrimaryBlue
                        : AppTheme.primaryBlue)
                    .withOpacity(_isHovered ? 0.3 : 0.2),
                blurRadius: _isHovered ? 12 : 8,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
              BoxShadow(
                color: (isDarkMode
                        ? AppTheme.darkPrimaryPurple
                        : AppTheme.primaryPurple)
                    .withOpacity(_isHovered ? 0.3 : 0.2),
                blurRadius: _isHovered ? 12 : 8,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xffEFFBFF),
                fontSize: _isHovered ? 25 : 24,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
              ),
              child: Text(widget.text),
            ),
          ),
        ),
      ),
    );
  }
}
