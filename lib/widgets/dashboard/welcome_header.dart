import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/theme_service.dart';
import 'package:provider/provider.dart';

class WelcomeHeader extends StatelessWidget {
  final VoidCallback onStatsPressed;
  final VoidCallback onSettingsPressed;
  final String userName;

  const WelcomeHeader({
    super.key,
    required this.onStatsPressed,
    required this.onSettingsPressed,
    this.userName = 'User', // Default value if no name provided
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Smart Recall',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppTheme.darkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.bar_chart,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: onStatsPressed,
                  tooltip: 'Statistics',
                ),
                Consumer<ThemeService>(
                  builder: (context, themeService, _) => IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return RotationTransition(
                          turns: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        themeService.darkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        key: ValueKey<bool>(themeService.darkMode),
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    onPressed: () => themeService.toggleTheme(),
                    tooltip: themeService.darkMode
                        ? 'Switch to Light Mode'
                        : 'Switch to Dark Mode',
              ),
            ),
            IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: isDarkMode ? Colors.white : Colors.black87,
          ),
                  onPressed: onSettingsPressed,
                  tooltip: 'Settings',
            ),
              ],
        ),
      ],
        ),
      ),
    );
  }
}
