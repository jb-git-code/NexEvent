import 'package:flutter/material.dart';

/// NexEvent — Polychrome color palette
/// Single source of truth. Import this everywhere instead of
/// hardcoding hex values inside each screen.
class AppColors {
  AppColors._();

  // ── Base ────────────────────────────────────────────────
  static const background = Colors.white;
  static const text = Color(0xFF14151A); // headings, primary text
  static const muted = Color(0xFF8A8D9A); // subtitles, timestamps
  static const card = Color(0xFFF3F4F7); // neutral card / chip fill
  static const border = Color(0xFFE7E8ED); // hairline borders
  static const navBg = Color(0xFF232742); // bottom nav background (navy/slate)

  // ── Primary ─────────────────────────────────────────────
  static const primary = Color(0xFF4361EE); // indigo-blue, main accent
  static const primaryDark = Color(0xFF2F49C9); // gradient end / pressed state
  static const primaryTint = Color(0x144361EE); // primary @ 8% opacity fill

  // ── Category / accent colors ───────────────────────────
  // Reused consistently: same category = same color everywhere
  // (Feed post, Explore chip, Communities channel, Services card).
  static const accentPurple = Color(0xFF9B6BFF); // Cultural / Clubs
  static const accentGreen = Color(0xFF20C997); // Tech / Campus Map
  static const accentOrange = Color(0xFFFF9F43); // Sports / Marketplace badge
  static const accentPink = Color(0xFFEE6C9C); // Marketplace / Announcements

  static const categoryColors = <String, Color>{
    'Keynote': primary,
    'Workshops': accentGreen,
    'Cultural': accentPurple,
    'Sports': accentOrange,
    'Marketplace': accentPink,
    'Tech': accentGreen,
  };

  // ── Map-specific ────────────────────────────────────────
  static const mapRiver = Color(0xFFBFDCF7);
  static const mapGreenZone = Color(0xFFE4F0D8);
  static const mapRoad = Color(0xFFD8DAE2);
  static const mapTrack = Color(0xFFFCD9C0);
  static const mapGateMarker = Color(0xFFFFCB77);
}