import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexevent/ui/app_colors.dart';

/// NexEvent — Text styles
/// Single source of truth for typography. Sizes/weights match what's
/// already used across Dashboard, Feed, Explore, Communities, Tickets.
///
/// Usage: `Text('Feed', style: AppTextStyles.h1)`
/// (If you want it to match the private `_Text` name used in some
/// existing widgets, just add: `typedef _Text = AppTextStyles;`
/// at the top of that file.)
class AppTextStyles {
  AppTextStyles._();

  static const _font = GoogleFonts.quicksand;

  // set a fontFamily here if you use a custom one

  // Screen-level titles — "Feed", "Explore", "Insti Feed"
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    letterSpacing: -0.3,
  );

  // Section headers — "Today's Schedule", "Services", "Your Channels"
  static const h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  // Card / list-item titles — event name, channel name, ticket title
  static const h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  // Standard paragraph / description text
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.4,
  );

  // Secondary / de-emphasized paragraph text (announcement previews, blurbs)
  static const bodyMuted = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.4,
  );

  // Meta text — timestamps, venue lines, helper text under a title
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  // Small chip / pill labels — category tags, "New!" badges
  static const chip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
  );

  // Button label text (color is set per-button via ButtonStyle)
  static const button = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  // Bottom-nav item labels
  static const navLabel = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
}

/// NexEvent — App theme
/// Wires AppColors + AppTextStyles into a MaterialApp ThemeData so
/// individual screens don't need to hardcode component styling.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      fontFamily: GoogleFonts.quicksand().fontFamily,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
        error: const Color(0xFFEF4444),
        brightness: Brightness.light,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h2,
        iconTheme: IconThemeData(color: AppColors.text),
      ),

      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        titleMedium: AppTextStyles.h3,
        bodyMedium: AppTextStyles.body,
        bodySmall: AppTextStyles.bodyMuted,
        labelSmall: AppTextStyles.caption,
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.button,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: AppColors.border, width: 1.4),
          textStyle: AppTextStyles.button,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        hintStyle: AppTextStyles.body.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.chip.copyWith(color: AppColors.text),
        secondaryLabelStyle: AppTextStyles.chip.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.text,
        contentTextStyle: AppTextStyles.body.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.h3,
        contentTextStyle: AppTextStyles.body,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
