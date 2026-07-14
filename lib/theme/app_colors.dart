import 'package:flutter/material.dart';

/// Central color palette for the app.
///
/// Usage: `AppColors.of(context).background`
///
/// This is structured so adding dark mode later is just filling in
/// [AppColors.dark] with real values and wiring a [ThemeMode] switch —
/// no widget code needs to change since everything reads through here.
class AppColors {
  final Brightness brightness;

  // Core surfaces
  final Color background;
  final Color surface; // cards, sheets
  final Color surfaceAlt; // secondary card fill (e.g. inner tiles)

  // Brand
  final Color primary; // main green accent
  final Color primaryMuted; // light green tint (chip/pill backgrounds)
  final Color onPrimary; // text/icons on top of primary

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary; // faint captions, timestamps

  // Borders / dividers
  final Color border;
  final Color divider;

  // Status
  final Color success;
  final Color warning;
  final Color error;

  // Utility
  final Color iconDefault;
  final Color shadow;

  const AppColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.primaryMuted,
    required this.onPrimary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.border,
    required this.divider,
    required this.success,
    required this.warning,
    required this.error,
    required this.iconDefault,
    required this.shadow,
  });

  static const AppColors light = AppColors(
    brightness: Brightness.light,
    background: Color(0xFFF7F9F7),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F4F1),
    primary: Color(0xFF2563EB),
    primaryMuted: Color(0xFFE4ECFD),
    onPrimary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A1D1B),
    textSecondary: Color(0xFF6B7570),
    textTertiary: Color(0xFF9AA39C),
    border: Color(0xFFE6EAE6),
    divider: Color(0xFFEDF0ED),
    success: Color(0xFF3A9D5D),
    warning: Color(0xFFC98A1F),
    error: Color(0xFFD64545),
    iconDefault: Color(0xFF3C443E),
    shadow: Color(0x14000000),
  );

  /// Placeholder — fill in when dark mode is implemented.
  /// Keeping the same shape as [light] means no other file changes
  /// when this gets real values.
  static const AppColors dark = AppColors(
    brightness: Brightness.dark,
    background: Color(0xFF121412),
    surface: Color(0xFF1C1F1D),
    surfaceAlt: Color(0xFF262A27),
    primary: Color(0xFF5B8DEF),
    primaryMuted: Color(0xFF1C2A47),
    onPrimary: Color(0xFF0B1220),
    textPrimary: Color(0xFFF2F4F2),
    textSecondary: Color(0xFFA9B2AA),
    textTertiary: Color(0xFF767E77),
    border: Color(0xFF2C302D),
    divider: Color(0xFF242725),
    success: Color(0xFF3A9D5D),
    warning: Color(0xFFE0A83A),
    error: Color(0xFFE05A5A),
    iconDefault: Color(0xFFD6DAD6),
    shadow: Color(0x33000000),
  );

  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}
