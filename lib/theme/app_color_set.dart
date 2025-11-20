import 'package:flutter/material.dart';

class AppColorSet {
  final Color primary;
  final Color secondary;
  final Color background;

  final Gradient? gradientLight;
  final Gradient? gradientDark;

  const AppColorSet({
    required this.primary,
    required this.secondary,
    required this.background,
    this.gradientLight,
    this.gradientDark,
  });
}
