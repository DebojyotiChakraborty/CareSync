import 'package:flutter/material.dart';

abstract class AppColors {
  // ═════════════════════════════════════════════════════════════════════════
  // CORE DESIGN TOKENS — flat, two neutrals + one fixed accent.
  // These are the canonical raw palette consumed by AppTheme / AppTokens.
  // The legacy members further down are retained only until per-screen
  // migration completes, then deleted.
  // ═════════════════════════════════════════════════════════════════════════

  // Neutrals (scaffold = page background, card = raised surface)
  static const Color scaffoldLight = Color(0xFFF5F5F5);
  static const Color scaffoldDark = Color(0xFF000000); // true black, OLED-friendly
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1A1A1A);

  // Text (primary = high-contrast ink, secondary = de-emphasised)
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF888888);
  static const Color textSecondaryDark = Color(0xFFDBD5D5); // warm off-white

  // Single fixed accent (reuse `primary` = 0xFFFF5200) + its foreground
  static const Color accentColor = primary; // 0xFFFF5200
  static const Color accentOn = Color(0xFFFFFFFF);

  // Semantic error (brightness-resolved)
  static const Color errorLightMode = Color(0xFFDC2626);
  static const Color errorDarkMode = Color(0xFFEF4444);

  // Skeleton / loading fills
  static const Color skeletonLight = Color(0xFFE0E0E0);
  static const Color skeletonDark = Color(0xFF2A2A2A);

  // ─────────────────────────────────────────────────────────────────────────
  // LEGACY — SOFT UI / PASTEL PALETTE (Reference Design)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color softPrimary = Color(0xFF8B5CF6);    // Main Purple
  static const Color softPrimaryLight = Color(0xFFA78BFA); // Lighter Purple
  static const Color softBackground = Color(0xFFF8F9FE); // Very light blue-grey tint
  
  static const Color softSurface = Colors.white;
  
  // Feature Colors
  static const Color softPurple = Color(0xFFEBE4FF);     // Light Purple background
  static const Color softBlue = Color(0xFFE0F2FE);       // Light Blue background
  static const Color softPink = Color(0xFFFEE2E2);       // Light Pink background
  static const Color softYellow = Color(0xFFFEF3C7);     // Light Yellow background

  static const Color textMain = Color(0xFF1E293B);       // Dark Slate
  static const Color textSub = Color(0xFF64748B);        // Muted Slate

  static const Color borderSoft = Color(0xFFF1F5F9);
  
  static const Color shadowSoft = Color(0xFFE2E8F0);     // Light shadow

  // ─────────────────────────────────────────────────────────────────────────
  // COMPATIBILITY ALIASES (Mapping Old -> New Theme)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFFF5200);        // V2 Brilliant Orange
  static const Color primaryLight = Color(0xFFFFE2D5);    // V2 Light Orange border accent
  static const Color primaryDark = Color(0xFFE04900);     // V2 Darker Orange
  static const Color primarySurface = Color(0xFFFFF4F0);  // V2 Soft Orange background surface
  static const Color brandBlack = Color(0xFF121212);      // V2 Brand Button / Ink Black
  static const Color cardBorder = Color(0xFFE2E8F0);      // V2 Standard Card Border Color

  // ─────────────────────────────────────────────────────────────────────────
  // NEUTRALS & SURFACES
  // ─────────────────────────────────────────────────────────────────────────
  static const Color backgroundLight = softBackground;   // Map active bg to soft
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  static const Color textPrimary = textMain;
  static const Color textSecondary = textSub;
  static const Color textLight = Color(0xFF94A3B8);

  static const Color border = borderSoft;
  static const Color shadow = shadowSoft;

  // ─────────────────────────────────────────────────────────────────────────
  // LEGACY ALIASES & ROLE COLORS (Restored for Compatibility)
  // ─────────────────────────────────────────────────────────────────────────

  // Roles - Mapped to modern pastel/vibrant tones
  static const Color patient = Color(0xFF38BDF8);        // Sky 400
  static const Color doctor = Color(0xFF8B5CF6);         // Violet 500
  static const Color pharmacist = Color(0xFF10B981);     // Emerald 500
  static const Color firstResponder = Color(0xFFEF4444); // Red 500

  // Semantics
  static const Color success = Color(0xFF22C55E);        // Green 500
  static const Color warning = Color(0xFFF59E0B);        // Amber 500
  static const Color error = Color(0xFFEF4444);          // Red 500
  static const Color info = Color(0xFF3B82F6);           // Blue 500

  // Light variants (for backgrounds)
  static const Color successLight = Color(0xFFDCFCE7);   // Green 100
  static const Color warningLight = Color(0xFFFEF3C7);   // Amber 100
  static const Color errorLight = Color(0xFFFEE2E2);     // Red 100
  static const Color infoLight = Color(0xFFDBEAFE);      // Blue 100

  // Aliases for refactored code
  static const Color secondary = Color(0xFF64748B);      // Slate 500 (Matches textSecondary)
  static const Color accent = Color(0xFFFB923C);         // Orange 400

  // Status & Trends (Mockup Specific)
  static const Color statusMorningBg = Color(0xFFFFEDD5);    // Orange 100
  static const Color statusMorningText = Color(0xFF9A3412);  // Orange 800
  static const Color statusTakenBg = Color(0xFFDCFCE7);      // Green 100
  static const Color statusTakenText = Color(0xFF166534);    // Green 800
  static const Color statusEveningBg = Color(0xFFDBEAFE);    // Blue 100
  static const Color statusEveningText = Color(0xFF1E40AF);  // Blue 800
  
  static const Color trendSuccess = Color(0xFF22C55E);       // Green 500
  static const Color trendWarning = Color(0xFFEF4444);       // Red 500
}