import 'package:flutter/material.dart';

class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double getPadding(BuildContext context) {
    if (isDesktop(context)) return 80.0;
    if (isTablet(context)) return 40.0;
    return 20.0;
  }

  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 120.0;
    if (isTablet(context)) return 60.0;
    return 20.0;
  }

  static double getVerticalPadding(BuildContext context) {
    if (isDesktop(context)) return 80.0;
    if (isTablet(context)) return 60.0;
    return 40.0;
  }

  static double getMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1200.0;
    if (isTablet(context)) return 900.0;
    return MediaQuery.of(context).size.width;
  }
}
