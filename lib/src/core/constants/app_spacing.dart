import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;

  static const double cardRadius = 8;
  static const double minTouchTarget = 48;
  static const double maxContentWidth = 1120;

  static BorderRadius get radius => BorderRadius.circular(cardRadius);

  static double pagePaddingFor(double width) {
    if (width >= 1000) {
      return xl;
    }
    if (width >= 600) {
      return lg;
    }
    return md;
  }
}
