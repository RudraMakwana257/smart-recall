import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_recall/widgets/centered_view.dart';
import 'package:smart_recall/widgets/navigation_bar.dart';
import 'package:smart_recall/widgets/gradient_button.dart';
import 'widgets/home_widgets/home_card.dart';
import 'widgets/home_sections/features_section.dart';
import 'widgets/home_sections/how_it_works_section.dart';
import 'widgets/home_sections/testimonials_section.dart';
import 'widgets/home_sections/footer_section.dart';
import 'services/theme_service.dart';
import 'utils/responsive.dart';
import 'utils/app_theme.dart';
import 'repositories/deck_repository.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(4, (_) => GlobalKey());
  List<double> _sectionOffsets = [];
  late AnimationController _ellipseAnimationController;
  late Animation<double> _ellipseFloatAnimation;

  final Map<String, bool> _sectionVisibility = {
    'hero': false,
    'features': false,
    'howItWorks': false,
    'testimonials': false,
  };

  @override
  void initState() {
    super.initState();
    _ellipseAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _ellipseFloatAnimation = Tween<double>(
      begin: -15.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _ellipseAnimationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSectionOffsets();
    });
  }

  void _calculateSectionOffsets() {
    _sectionOffsets = _sectionKeys.map((key) {
      final RenderBox? renderBox =
          key.currentContext?.findRenderObject() as RenderBox?;
      return renderBox?.localToGlobal(Offset.zero).dy ?? 0.0;
    }).toList();
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ellipseAnimationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSection({
    required String sectionId,
    required Widget child,
  }) {
    return VisibilityDetector(
      key: Key(sectionId),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.3 &&
            !_sectionVisibility[sectionId]!) {
          setState(() {
            _sectionVisibility[sectionId] = true;
          });
        }
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
        opacity: _sectionVisibility[sectionId]! ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOut,
          offset: _sectionVisibility[sectionId]!
              ? Offset.zero
              : const Offset(0, 0.2),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          if (!themeService.darkMode)
            AnimatedBuilder(
              animation: _ellipseFloatAnimation,
              builder: (context, child) {
                return Positioned(
                  right: 0,
                  top: _ellipseFloatAnimation.value,
                  child: Container(
                    width: Responsive.isMobile(context)
                        ? screenWidth * 0.3
                        : screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.1),
                          AppTheme.primaryPurple.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          Column(
            children: [
              CasNavigationBar(
                scrollController: _scrollController,
                sectionOffsets: _sectionOffsets,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      Container(
                        key: _sectionKeys[0],
                        child: _buildAnimatedSection(
                          sectionId: 'hero',
                          child: _buildHeroSection(),
                        ),
                      ),
                      Container(
                        key: _sectionKeys[1],
                        child: _buildAnimatedSection(
                          sectionId: 'features',
                          child: FeaturesSection(),
                        ),
                      ),
                      Container(
                        key: _sectionKeys[2],
                        child: _buildAnimatedSection(
                          sectionId: 'howItWorks',
                          child: HowItWorksSection(),
                        ),
                      ),
                      Container(
                        key: _sectionKeys[3],
                        child: _buildAnimatedSection(
                          sectionId: 'testimonials',
                          child: TestimonialsSection(),
                        ),
                      ),
                      const FooterSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _homeContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = Provider.of<ThemeService>(context).darkMode;

    return SizedBox(
      width: Responsive.isMobile(context) ? screenWidth * 0.9 : 566,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: isDarkMode
                    ? [AppTheme.darkPrimaryBlue, AppTheme.darkPrimaryPurple]
                    : [const Color(0xff2496b8), const Color(0xffa53f6f)],
                begin: Alignment.bottomLeft,
                end: Alignment.topCenter,
              ).createShader(bounds);
            },
            child: Text(
              'Remember More,\nForget Less',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 0.9,
                fontFamily: 'Road Rage',
                fontSize: Responsive.isMobile(context)
                    ? screenWidth * 0.08
                    : Responsive.isTablet(context)
                        ? 60
                        : 72,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  Responsive.isMobile(context) ? screenWidth * 0.05 : 35,
            ),
            child: Text(
              'Master any subject 2x faster using smart flashcards.\nPowered by spaced repetition',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.isMobile(context)
                    ? screenWidth * 0.04
                    : Responsive.isTablet(context)
                        ? 20
                        : 24,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          SizedBox(
            width: Responsive.isMobile(context) ? double.infinity : null,
            child: GradientButton(
              text: 'Create Your First Deck',
              onPressed: () {
                Navigator.pushNamed(context, '/create-deck-form').then((value) {
                  // After creating deck, check if we should navigate to dashboard
                  final deckRepository = DeckRepository();
                  deckRepository.getAllDecks().then((decks) {
                    if (decks.isNotEmpty) {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  });
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return CenteredView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Responsive.getVerticalPadding(context),
          horizontal: Responsive.getHorizontalPadding(context),
        ),
        child: Responsive.isMobile(context)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _homeContent(context),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.06),
                  const FlashCardHome(),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: _homeContent(context),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                  const Expanded(
                    flex: 2,
                    child: FlashCardHome(),
                  ),
                ],
              ),
      ),
    );
  }
}
