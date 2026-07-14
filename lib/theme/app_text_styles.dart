import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central typography scale. Pulls color from [AppColors] so it stays
/// theme-aware; call `AppTextStyles.of(context)` to get an instance
/// bound to the current brightness.
class AppTextStyles {
  final AppColors colors;
  const AppTextStyles(this.colors);

  static AppTextStyles of(BuildContext context) {
    return AppTextStyles(AppColors.of(context));
  }

  TextStyle get _base => GoogleFonts.inter();

  // Headings
  TextStyle get h1 => _base.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.2,
        letterSpacing: -0.4,
      );

  TextStyle get h2 => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
        height: 1.25,
        letterSpacing: -0.2,
      );

  TextStyle get h3 => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
        height: 1.3,
      );

  // Body
  TextStyle get bodyLarge => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.4,
      );

  TextStyle get bodyMedium => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
        height: 1.4,
      );

  TextStyle get bodySecondary => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
        height: 1.4,
      );

  // Captions / meta
  TextStyle get caption => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textTertiary,
        height: 1.3,
      );

  // Buttons / labels
  TextStyle get button => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.onPrimary,
        height: 1.2,
      );

  TextStyle get label => _base.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
        height: 1.2,
        letterSpacing: 0.1,
      );
}