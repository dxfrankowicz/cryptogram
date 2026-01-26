import 'package:flutter/material.dart';

/// Colors related to the KeyMotion brand.
class AppColors {
  /// Tint1 for primary color. Used for background scaffold or dark
  /// text appearance.
  static const primary = const Color(0xFF00B0FF); // Neonowy błękit;

  /// Shade1 for primary color. Used for light text appearance and icons.
  static const shade1 = Color(0xFF2C2929);

  /// Shade2 for primary color.
  static const shade2 = Color(0xFF4B4B4B);

  /// Error color
  static const error = Color(0xFFE03B3B);

  /// Warning color
  static const warning = Color(0xFFAB9A00);

  /// Success color
  static const success = Color(0xFF388F40);

  static Color highlight = Colors.blueAccent.withOpacity(0.75);
  static Color highlightSecond = Colors.green.withOpacity(0.75);
}
