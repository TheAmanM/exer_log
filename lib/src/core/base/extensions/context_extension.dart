import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  /// Returns height of the screen
  double get height => MediaQuery.of(this).size.height;

  /// Return width of the screen
  double get width => MediaQuery.of(this).size.width;

  /// Snack bar
  ScaffoldFeatureController showSnackBar(String text) =>
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(content: Text(text)),
      );
}
