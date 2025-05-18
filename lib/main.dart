import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_view.dart';
import 'models/deck_model.dart';
import 'screens/add_flashcards_screen.dart';
import 'screens/create_deck_screen.dart';
import 'screens/review_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/theme_service.dart';
import 'utils/app_theme.dart';
import 'repositories/deck_repository.dart';
import 'services/quiz_service.dart';
import 'services/srs_service.dart';
import 'services/learning_progress_service.dart';
import 'screens/quiz_view.dart';
import 'services/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters if needed
  // Hive.registerAdapter(DeckAdapter());
  // Hive.registerAdapter(FlashcardAdapter());

  // Open Hive boxes
  await Hive.openBox('flashcards');
  await Hive.openBox('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService(prefs)),
        ChangeNotifierProvider(create: (_) => DeckRepository()..init()),
        ChangeNotifierProvider(create: (_) => SRSService(prefs)),
        ChangeNotifierProvider(create: (_) => ReminderService(prefs)),
        ChangeNotifierProvider(
          create: (context) => QuizService(
            prefs,
            Provider.of<SRSService>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LearningProgressService(
            Provider.of<SRSService>(context, listen: false),
            Provider.of<QuizService>(context, listen: false),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Smart Recall',
          debugShowCheckedModeBanner: false,
          theme: themeService.theme,
          home: const InitialViewSelector(),
          routes: {
            '/dashboard': (context) => const DashboardScreen(),
            '/create-deck-form': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is Deck) {
                return CreateDeckScreen(
                    showFormDirectly: true, initialDeck: args);
              }
              return const CreateDeckScreen(showFormDirectly: true);
            },
            '/stats': (context) => const StatsScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/add-flashcard': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is Deck) {
                return AddFlashcardScreen(deck: args);
              }
              return const Scaffold(
                body: Center(child: Text('Invalid deck reference')),
              );
            },
            '/review': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is Deck) {
                return ReviewScreen(deck: args);
              }
              return const Scaffold(
                body: Center(child: Text('Invalid deck reference')),
              );
            },
            '/quiz': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              if (args is Deck) {
                return QuizView(
                  deckId: args.id,
                  cardIds: args.flashcards.map((f) => f.id).toList(),
                );
              }
              return const Scaffold(
                body: Center(child: Text('Invalid deck reference')),
              );
            },
          },
        );
      },
    );
  }
}

class InitialViewSelector extends StatefulWidget {
  const InitialViewSelector({super.key});

  @override
  State<InitialViewSelector> createState() => _InitialViewSelectorState();
}

class _InitialViewSelectorState extends State<InitialViewSelector> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DeckRepository>(
      builder: (context, deckRepository, child) {
        return FutureBuilder<List<Deck>>(
          future: deckRepository.getAllDecks(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Error loading decks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please try again later',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show dashboard only if there are decks, otherwise show home view
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return const DashboardScreen();
            }

            return const HomeView();
          },
        );
      },
    );
  }
}

// Ensure fonts are declared in pubspec.yaml:
/*
  fonts:
    - family: Road Rang
      fonts:
        - asset: assets/fonts/RoadRang-Regular.ttf
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Medium.ttf
          weight: 500
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
*/
