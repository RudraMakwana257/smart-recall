import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../repositories/deck_repository.dart';
import '../services/srs_service.dart';
import '../services/quiz_service.dart';
import '../services/reminder_service.dart';
import '../utils/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _clearAllData(BuildContext context) async {
    final deckRepository = Provider.of<DeckRepository>(context, listen: false);
    final srsService = Provider.of<SRSService>(context, listen: false);
    final quizService = Provider.of<QuizService>(context, listen: false);

    // Clear all data
    await deckRepository.clearAllDecks();
    await srsService.clearAllData();
    await quizService.resetStats();

    // Navigate to home view
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void _showDailyGoalDialog(
      BuildContext context, ReminderService reminderService) {
    final controller =
        TextEditingController(text: reminderService.dailyGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        ),
        title: const Text('Set Daily Review Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Number of cards',
            hintText: 'Enter a number between 1 and 100',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0 && value <= 100) {
                reminderService.setDailyGoal(value);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final reminderService = Provider.of<ReminderService>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Appearance Section
          Text(
            'Appearance',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.darkPrimaryBlue.withOpacity(0.1)
                          : AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: isDarkMode
                          ? AppTheme.darkPrimaryBlue
                          : AppTheme.primaryBlue,
                    ),
                  ),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeService.darkMode,
                    onChanged: (value) {
                      themeService.toggleTheme();
                    },
                    activeColor: isDarkMode
                        ? AppTheme.darkPrimaryBlue
                        : AppTheme.primaryBlue,
                    activeTrackColor: (isDarkMode
                            ? AppTheme.darkPrimaryBlue
                            : AppTheme.primaryBlue)
                        .withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Study Settings Section
          Text(
            'Study Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.darkPrimaryPurple.withOpacity(0.1)
                          : AppTheme.primaryPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  title: const Text('Daily Review Goal'),
                  subtitle: Text('${reminderService.dailyGoal} cards'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _showDailyGoalDialog(context, reminderService),
                  ),
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  height: 1,
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.darkPrimaryPurple.withOpacity(0.1)
                          : AppTheme.primaryPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  title: const Text('Review Reminders'),
                  trailing: Switch(
                    value: reminderService.isReminderEnabled,
                    onChanged: (value) => reminderService.toggleReminder(value),
                    activeThumbColor: AppTheme.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Data Management Section
          Text(
            'Data Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.red.withOpacity(0.1)
                          : Colors.red[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.red[400],
                    ),
                  ),
                  title: const Text('Clear All Data'),
                  subtitle: const Text('This action cannot be undone'),
                  onTap: () => _clearAllData(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // About Section
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.darkPrimaryBlue.withOpacity(0.1)
                          : AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  title: const Text('Version'),
                  subtitle: Text('v$_version ($_buildNumber)'),
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  height: 1,
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppTheme.darkPrimaryBlue.withOpacity(0.1)
                          : AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.code,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  title: const Text('Developer'),
                  subtitle: const Text('Made by Rudra Makwana'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
