import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../utils/responsive.dart';
import '../utils/app_theme.dart';

class CasNavigationBar extends StatefulWidget {
  final ScrollController scrollController;
  final List<double> sectionOffsets;

  const CasNavigationBar({
    super.key,
    required this.scrollController,
    required this.sectionOffsets,
  });

  @override
  State<CasNavigationBar> createState() => _CasNavigationBarState();
}

class _CasNavigationBarState extends State<CasNavigationBar>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final List<String> _navItems = ['Home', 'Features', 'How it works', 'Stats'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Listen to scroll changes to update selected index
    widget.scrollController.addListener(_updateSelectedIndex);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.scrollController.removeListener(_updateSelectedIndex);
    super.dispose();
  }

  void _updateSelectedIndex() {
    final offset = widget.scrollController.offset;
    for (int i = widget.sectionOffsets.length - 1; i >= 0; i--) {
      if (offset >= widget.sectionOffsets[i] - 100) {
        if (_selectedIndex != i) {
          setState(() => _selectedIndex = i);
        }
        break;
      }
    }
  }

  void _scrollToSection(int index) {
    widget.scrollController.animateTo(
      widget.sectionOffsets[index],
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Widget _buildThemeToggle() {
    final themeService = Provider.of<ThemeService>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return RotationTransition(
              turns: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Icon(
            themeService.darkMode ? Icons.light_mode : Icons.dark_mode,
            key: ValueKey<bool>(themeService.darkMode),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF004059),
            size: 24,
          ),
        ),
        onPressed: () {
          themeService.toggleTheme();
        },
        tooltip: themeService.darkMode
            ? 'Switch to Light Mode'
            : 'Switch to Dark Mode',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : const Color(0xFFD9E2EC),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF004059).withOpacity(0.5)
                : const Color(0xFF004059),
            width: 5,
          ),
        ),
      ),
      child:
          Responsive.isMobile(context) ? _buildMobileNav() : _buildDesktopNav(),
    );
  }

  Widget _buildDesktopNav() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Smart Recall',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF004059),
              fontSize: 48,
              fontFamily: 'Road Rage',
            ),
          ),
        ),
        const Spacer(),
        for (int i = 0; i < _navItems.length; i++)
          _DesktopNavItem(
            title: _navItems[i],
            isActive: _selectedIndex == i,
            onHover: (isHovering) {
              setState(() {
                if (isHovering && _selectedIndex != i) {
                  _animationController.forward();
                } else if (!isHovering && _selectedIndex != i) {
                  _animationController.reverse();
                }
              });
            },
            onTap: () => _scrollToSection(i),
          ),
        _buildThemeToggle(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileNav() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Smart Recall',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF004059),
                  fontSize: 32,
                  fontFamily: 'Road Rage',
                ),
              ),
              const Spacer(),
              _buildThemeToggle(),
              IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _animationController,
                  size: 32,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF004059),
                ),
                onPressed: _toggleMenu,
              ),
            ],
          ),
        ),
        if (_isMenuOpen)
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFD9E2EC),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      for (int i = 0; i < _navItems.length; i++)
                        _MobileNavItem(
                          title: _navItems[i],
                          isActive: _selectedIndex == i,
                          onTap: () {
                            _scrollToSection(i);
                            _toggleMenu();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DesktopNavItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final Function(bool) onHover;
  final VoidCallback onTap;

  const _DesktopNavItem({
    required this.title,
    required this.isActive,
    required this.onHover,
    required this.onTap,
  });

  @override
  State<_DesktopNavItem> createState() => _DesktopNavItemState();
}

class _DesktopNavItemState extends State<_DesktopNavItem>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _widthAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 60),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 60, end: 40),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Run animation if item is initially active
    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_DesktopNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: widget.isActive
                        ? const Color(0xFF004059)
                        : _isHovering
                            ? const Color(0xFF2496b8)
                            : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final decoration = widget.isActive
                        ? BoxDecoration(
                            gradient:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.darkModeGradient
                                    : AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(10),
                          )
                        : BoxDecoration(
                            color: _isHovering
                                ? Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppTheme.darkPrimaryBlue.withOpacity(0.3)
                                    : const Color(0xFF2496b8)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          );

                    return Container(
                      height: 3,
                      width: widget.isActive
                          ? _widthAnimation.value
                          : _isHovering
                              ? 30
                              : 0,
                      decoration: decoration,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileNavItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _MobileNavItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2496b8).withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isActive ? const Color(0xFF004059) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
