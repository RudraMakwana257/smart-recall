import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;

  FadePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class SlidePageRoute<T> extends PageRoute<T> {
  final Widget child;
  final Duration duration;
  final SlideDirection direction;

  SlidePageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.direction = SlideDirection.right,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    Offset begin;
    switch (direction) {
      case SlideDirection.right:
        begin = const Offset(1.0, 0.0);
        break;
      case SlideDirection.left:
        begin = const Offset(-1.0, 0.0);
        break;
      case SlideDirection.up:
        begin = const Offset(0.0, 1.0);
        break;
      case SlideDirection.down:
        begin = const Offset(0.0, -1.0);
        break;
    }

    var slideAnimation = Tween(
      begin: begin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      ),
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

enum SlideDirection {
  right,
  left,
  up,
  down,
}

extension PageRouteExtension on BuildContext {
  Future<T?> pushWithTransition<T extends Object?>(
    Widget page, {
    bool fade = false,
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(this).push<T>(
      fade
          ? FadePageRoute(
              child: page,
              duration: duration,
            )
          : SlidePageRoute(
              child: page,
              direction: direction,
              duration: duration,
            ),
    );
  }

  Future<T?>
      pushReplacementWithTransition<T extends Object?, TO extends Object?>(
    Widget page, {
    bool fade = false,
    SlideDirection direction = SlideDirection.right,
    Duration duration = const Duration(milliseconds: 300),
    TO? result,
  }) {
    return Navigator.of(this).pushReplacement<T, TO>(
      fade
          ? FadePageRoute(
              child: page,
              duration: duration,
            )
          : SlidePageRoute(
              child: page,
              direction: direction,
              duration: duration,
            ),
      result: result,
    );
  }
}
